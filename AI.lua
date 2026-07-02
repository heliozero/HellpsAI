-- ============================================================
-- Metadata
-- Nome: HellpsAI
-- Versao: 1.0
-- ============================================================
-- ============================================================
-- AI.lua — Loop principal do Homunculus
-- Estados: GUARD | FOLLOW | ATTACK
-- ============================================================

local function load_local(name)
    local candidates = {
        "./AI/USER_AI/" .. name,
        "./" .. name,
    }

    for i = 1, #candidates do
        local ok = pcall(dofile, candidates[i])
        if ok then return end
    end

    error("Nao foi possivel carregar " .. name)
end

load_local("Const.lua")
load_local("Config.lua")
load_local("Tatics.lua")
load_local("Logger.lua")

Logger.init({ enabled = Config.LogEnabled, dir = Config.LogDir })
Logger.info("=== AI carregada ===")

-- ------------------------------------------------------------
-- Estado global
-- ------------------------------------------------------------

local GUARD_ST  = 0
local FOLLOW_ST = 1
local ATTACK_ST = 2
local MOVE_CMD_ST = 3

local MyState = GUARD_ST
local MyEnemy = 0
local MyMoveX = 0
local MyMoveY = 0
local MyStart = GetTick()
local LastIdleWalk = 0
local LastTargetScan = 0
local LastAttackCommand = 0
local LastSkillTry = 0
local LastScanDebug = 0
local CurrentSkillSlot = 1
local CurrentCombatTarget = 0
local AttackedSinceLastSkill = false
local LastTargetProgress = 0
local LastObservedTargetDistance = 999

local BASIC_ATTACK_RETRY_INTERVAL = 120

pcall(math.randomseed, MyStart)

MyID = MyID or 0

-- ------------------------------------------------------------
-- Utilitários
-- ------------------------------------------------------------

-- Distância de Chebyshev entre dois IDs (diagonal = 1 célula)
local function DistRect(id1, id2)
    local x1, y1 = GetV(V_POSITION, id1)
    local x2, y2 = GetV(V_POSITION, id2)
    if x1 == -1 or x2 == -1 then return 999 end
    return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
end

local function GetHomunculusType()
    return GetV(V_HOMUNTYPE, MyID) or 0
end

local function ResetCombatRotation(targetID)
    if CurrentCombatTarget ~= targetID then
        CurrentCombatTarget = targetID or 0
        CurrentSkillSlot = 1
        AttackedSinceLastSkill = false
        LastTargetProgress = GetTick()
        LastObservedTargetDistance = 999
    end
end

local function GetReturnState(owner)
    if DistRect(MyID, owner) > Config.FollowDistance then
        return FOLLOW_ST
    end
    return GUARD_ST
end

local function GetCurrentHomContext()
    local homType = GetHomunculusType()
    local homKey, homBucket = GetHomSkillKey(homType)
    local homSkills = GetHomSkills(homType)
    return homKey, homBucket, homSkills
end

local function NormalizeHomConfigKey(value)
    if type(value) == "number" then
        return GetHomSkillKey(value)
    end

    if type(value) ~= "string" then
        return nil
    end

    local normalized = string.lower(value)
    if normalized == "amstir" then
        return "amistr"
    end

    return normalized
end

local function ResolveConfiguredHomTypes(settings)
    local currentKey, currentBucket = GetCurrentHomContext()
    local baseKey = NormalizeHomConfigKey(settings.hom_type or Config.HomType)
    local sKey = NormalizeHomConfigKey(settings.hom_s_type or Config.HomSType)

    if not baseKey and currentBucket == "hom" then
        baseKey = currentKey
    end

    if not sKey and currentBucket == "hom_s" then
        sKey = currentKey
    end

    return baseKey, sKey, currentBucket
end

local function BuildCombatSettings(mobType)
    local tactic = GetTactic(mobType)
    local settings = {
        hom_type = Config.HomType,
        hom_s_type = Config.HomSType,
        limit_area_stopped = Config.LimitAreaStopped,
        limit_area_following = Config.LimitAreaFollowing,
        aggro_hp = Config.AggroHP,
        aggro_sp = Config.AggroSP,
    }

    for key, value in pairs(tactic) do
        settings[key] = value
    end

    return settings
end

local function GetBattleMode(settings)
    local mode = settings.battle_mode or "basic"
    if mode == "default" then
        return "basic"
    end
    return mode
end

local function GetCombatBounds(settings)
    local ownerMotion = GetV(V_MOTION, GetV(V_OWNER, MyID))
    if ownerMotion == MOTION_MOVE then
        return settings.limit_area_following or 9
    end
    return settings.limit_area_stopped or 14
end

-- Move o homunculus para até `range` células do dono
local function MoveNearOwner(range)
    local hx, hy = GetV(V_POSITION, MyID)
    local ox, oy = GetV(V_POSITION, GetV(V_OWNER, MyID))
    if hx == -1 or ox == -1 then return end

    local dx = hx
    local dy = hy
    if     hx > ox + range then dx = ox + range
    elseif hx < ox - range then dx = ox - range end
    if     hy > oy + range then dy = oy + range
    elseif hy < oy - range then dy = oy - range end

    Move(MyID, dx, dy)
end

local function MoveTowardTarget(targetID, attackRange)
    local hx, hy = GetV(V_POSITION, MyID)
    local tx, ty = GetV(V_POSITION, targetID)
    if hx == -1 or tx == -1 then return false end

    local range = math.max(1, attackRange or 1)
    local dx = tx
    local dy = ty

    if hx < tx then dx = tx - range end
    if hx > tx then dx = tx + range end
    if hy < ty then dy = ty - range end
    if hy > ty then dy = ty + range end

    Move(MyID, dx, dy)
    return true
end

local function AdjustOpp(x, y, ox, oy)
    local dx = ox - x
    local dy = oy - y
    return x + (2 * dx), y + (2 * dy)
end

local function AdjustCW(x, y, ox, oy)
    local dx = x - ox
    local dy = y - oy
    return ox - dy, oy + dx
end

local function AdjustCCW(x, y, ox, oy)
    local dx = x - ox
    local dy = y - oy
    return ox + dy, oy - dx
end

local function GetDanceCell(targetID)
    local hx, hy = GetV(V_POSITION, MyID)
    local tx, ty = GetV(V_POSITION, targetID)
    if hx == -1 or tx == -1 then return nil end

    local pick = math.random(3)
    if pick == 1 then
        return AdjustCW(hx, hy, tx, ty)
    elseif pick == 2 then
        return AdjustCCW(hx, hy, tx, ty)
    end

    return AdjustOpp(hx, hy, tx, ty)
end

local function TryDanceAttack(settings, targetID)
    if not settings.dance_attack then return false end

    local owner = GetV(V_OWNER, MyID)
    local attackRange = GetV(V_ATTACKRANGE, MyID) or 1
    if attackRange > 2 then return false end
    if DistRect(MyID, targetID) > attackRange then return false end

    local nx, ny = GetDanceCell(targetID)
    local ox, oy = GetV(V_POSITION, owner)
    if not nx or ox == -1 then return false end
    if math.max(math.abs(nx - ox), math.abs(ny - oy)) > GetCombatBounds(settings) then
        return false
    end

    Move(MyID, nx, ny)
    Logger.debug("DANCE alvo id=" .. tostring(targetID) .. " pos=(" .. tostring(nx) .. "," .. tostring(ny) .. ")")
    return true
end

local function HPPct(id)
    local hp    = GetV(V_HP,    id)
    local maxhp = GetV(V_MAXHP, id)
    if not maxhp or maxhp == 0 then return 100 end
    return hp / maxhp * 100
end

local function SPPct(id)
    local sp    = GetV(V_SP,    id)
    local maxsp = GetV(V_MAXSP, id)
    if not maxsp or maxsp == 0 then return 100 end
    return sp / maxsp * 100
end

local function OwnerIsStopped(owner)
    return GetV(V_MOTION, owner) ~= MOTION_MOVE
end

local function GetIdleWalkDest(owner)
    local ox, oy = GetV(V_POSITION, owner)
    if ox == -1 or oy == -1 then return nil end

    local radius = math.max(1, Config.FollowDistance or 1)
    local angle = math.random() * math.pi * 2
    local dx = math.floor(math.sin(angle) * radius + 0.5)
    local dy = math.floor(math.cos(angle) * radius + 0.5)

    if dx == 0 and dy == 0 then
        dx = radius
    end

    return ox + dx, oy + dy
end

local function TryIdleWalk(owner)
    if not Config.IdleWalkEnabled then return end
    if not OwnerIsStopped(owner) then return end
    if SPPct(MyID) < (Config.IdleWalkSP or 0) then return end
    if GetTick() < LastIdleWalk + (Config.IdleWalkInterval or 0) then return end

    local destx, desty = GetIdleWalkDest(owner)
    if not destx then return end

    Move(MyID, destx, desty)
    LastIdleWalk = GetTick()
    Logger.debug(string.format("IDLEWALK (%d,%d)", destx, desty))
end

local function MeetsAggroThresholds(settings)
    local aggroHP = settings.aggro_hp or 0
    local aggroSP = settings.aggro_sp or 0

    if HPPct(MyID) <= aggroHP then return false end
    if aggroSP > 0 and SPPct(MyID) <= aggroSP then return false end

    return true
end

local function AppendConfiguredSkills(sequence, skillConfig)
    if type(skillConfig) ~= "table" then return end

    for index = 1, 8 do
        local skillKey = skillConfig[string.format("slot_%02d", index)]
        if skillKey and skillKey ~= false then
            sequence[#sequence + 1] = skillKey
        end
    end
end

local function GetConfiguredSkillSequence(settings)
    local sequence = {}

    local baseKey, sKey, currentBucket = ResolveConfiguredHomTypes(settings)

    if baseKey and type(settings.hom) == "table" then
        AppendConfiguredSkills(sequence, settings.hom[baseKey])
    end

    if currentBucket == "hom_s" and sKey and type(settings.hom_s) == "table" then
        AppendConfiguredSkills(sequence, settings.hom_s[sKey])
    end

    return sequence
end

local function LookupSkillDefinition(skillID)
    return GetHomSkillDefinition(skillID)
end

local function TryCastNamedSkill(skillID, targetID, ownerID)
    local skill = LookupSkillDefinition(skillID)
    if not skill then return false end
    if skill.skill_type == "passive" then return false end

    local skillLevel = tonumber(skill.level)
        or tonumber(skill.level_max)
        or tonumber(skill.max_level)

    if not skillLevel then
        if type(skill.range) == "table" then
            skillLevel = #skill.range
        elseif type(skill.sp_cost) == "table" then
            skillLevel = #skill.sp_cost
        end
    end

    if not skillLevel or skillLevel < 1 then
        Logger.warn("SKILL sem nivel valido: " .. tostring(skill.skill_name or skillID) .. " [" .. tostring(skillID) .. "]")
        return false
    end

    local actionArea = skill.action_area
    if not actionArea then
        actionArea = "target"
    end

    if actionArea == "ground" then
        local groundTargetID = targetID
        local groundTarget = skill.target or "enemy"
        if groundTarget == "owner" then
            groundTargetID = ownerID
        elseif groundTarget == "self" then
            groundTargetID = MyID
        end

        local tx, ty = GetV(V_POSITION, groundTargetID)
        if tx == -1 or ty == -1 then return false end
        SkillGround(MyID, skillLevel, skillID, tx, ty)
    else
        local skillTarget = skill.target or "enemy"
        if skillTarget == "self" then
            SkillObject(MyID, skillLevel, skillID, MyID)
        elseif skillTarget == "owner" then
            SkillObject(MyID, skillLevel, skillID, ownerID)
        elseif skillTarget == "enemy" then
            SkillObject(MyID, skillLevel, skillID, targetID)
        else
            return false
        end
    end

    Logger.debug("SKILL " .. tostring(skill.skill_name or skillID) .. " [" .. tostring(skillID) .. "] -> " .. tostring(targetID))
    return true
end

local function TryUseConfiguredSkill(settings, targetID, ownerID)
    local sequence = GetConfiguredSkillSequence(settings)
    if #sequence == 0 then return false end

    for attempt = 1, #sequence do
        local slot = ((CurrentSkillSlot + attempt - 2) % #sequence) + 1
        local skillID = sequence[slot]
        if TryCastNamedSkill(skillID, targetID, ownerID) then
            CurrentSkillSlot = (slot % #sequence) + 1
            LastSkillTry = GetTick()
            AttackedSinceLastSkill = false
            return true
        end
    end

    return false
end

-- Encontra o inimigo mais próximo do dono dentro da área de atuação
local function FindTarget()
    local owner  = GetV(V_OWNER, MyID)
    local actors = GetActors()
    local best   = nil
    local bestD  = 999
    local bestPriority = -1
    local monsterCount = 0
    local nearestMonster = 999

    for _, id in ipairs(actors) do
        if IsMonster(id) == 1 then
            monsterCount = monsterCount + 1
            local motion = GetV(V_MOTION, id)
            if motion ~= MOTION_DEAD then
                local mobType = GetV(V_HOMUNTYPE, id) or 0
                local settings = BuildCombatSettings(mobType)
                local battleMode = GetBattleMode(settings)
                local dOwner = DistRect(owner, id)
                local dSelf = DistRect(MyID, id)
                local d = math.min(dOwner, dSelf)
                if d < nearestMonster then
                    nearestMonster = d
                end
                local bounds = GetCombatBounds(settings)
                local priority = tonumber(settings.target_priority or 0) or 0

                if battleMode ~= "ignore" and d <= bounds and MeetsAggroThresholds(settings) then
                    if priority > bestPriority or (priority == bestPriority and d < bestD) then
                        bestPriority = priority
                        bestD = d
                        best = id
                    end
                end
            end
        end
    end
    return best, monsterCount, nearestMonster
end

local function AcquireNextTargetOrFallback(fallbackState, reason)
    local nextTarget = FindTarget()
    if nextTarget and nextTarget ~= MyEnemy then
        MyEnemy = nextTarget
        ResetCombatRotation(nextTarget)
        MyState = ATTACK_ST
        Logger.debug("ATTACK->ATTACK retarget id=" .. tostring(nextTarget) .. " motivo=" .. tostring(reason))
        return true
    end

    MyEnemy = 0
    ResetCombatRotation(0)
    MyState = fallbackState
    Logger.debug("ATTACK->" .. (fallbackState == FOLLOW_ST and "FOLLOW" or "GUARD") .. " " .. tostring(reason))
    return false
end

-- ------------------------------------------------------------
-- Handlers de estado
-- ------------------------------------------------------------

local function OnGUARD()
    local owner = GetV(V_OWNER, MyID)
    local settings = BuildCombatSettings(0)
    local dist  = DistRect(MyID, owner)

    if dist > Config.FollowDistance then
        MyState = FOLLOW_ST
        Logger.debug("GUARD->FOLLOW dist=" .. dist)
        return
    end

    if GetTick() >= LastTargetScan + (settings.target_scan_interval or 400) and MeetsAggroThresholds(settings) then
        LastTargetScan = GetTick()
        local t, monsterCount, nearestMonster = FindTarget()
        if t then
            MyEnemy = t
            ResetCombatRotation(t)
            MyState = ATTACK_ST
            Logger.debug("GUARD->ATTACK id=" .. t)
            return
        end

        if GetTick() >= LastScanDebug + 2000 then
            LastScanDebug = GetTick()
            Logger.debug("SCAN sem alvo valido monsters=" .. tostring(monsterCount or 0) .. " nearest=" .. tostring(nearestMonster or 999))
        end
    end

    TryIdleWalk(owner)
end

local function OnFOLLOW()
    local owner = GetV(V_OWNER, MyID)
    local dist  = DistRect(MyID, owner)

    if dist <= Config.FollowDistance then
        MyState = GUARD_ST
        Logger.debug("FOLLOW->GUARD")
        return
    end

    MoveNearOwner(Config.FollowDistance)
end

local function OnMOVE_CMD_ST()
    local owner = GetV(V_OWNER, MyID)
    if DistRect(owner, MyID) > math.max(15, Config.LimitAreaStopped or 11) then
        MyState = FOLLOW_ST
        Logger.debug("MOVE_CMD->FOLLOW longe do dono")
        return
    end

    local x, y = GetV(V_POSITION, MyID)
    if x == MyMoveX and y == MyMoveY then
        MyState = GUARD_ST
        Logger.debug("MOVE_CMD->GUARD chegou")
        return
    end

    if GetV(V_MOTION, MyID) ~= MOTION_MOVE then
        Move(MyID, MyMoveX, MyMoveY)
    end
end

local function OnATTACK()
    local owner = GetV(V_OWNER, MyID)
    local mobType = GetV(V_HOMUNTYPE, MyEnemy) or 0
    local settings = BuildCombatSettings(mobType)
    local battleMode = GetBattleMode(settings)

    ResetCombatRotation(MyEnemy)

    local ownerTargetDistance = MyEnemy ~= 0 and DistRect(owner, MyEnemy) or 999
    if ownerTargetDistance > GetCombatBounds(settings) then
        AcquireNextTargetOrFallback(GetReturnState(owner), "alvo fora da area")
        return
    end

    if MyEnemy == 0 then
        AcquireNextTargetOrFallback(GetReturnState(owner), "sem alvo")
        return
    end

    local motion = GetV(V_MOTION, MyEnemy)
    if motion == MOTION_DEAD then
        AcquireNextTargetOrFallback(GetReturnState(owner), "alvo morto")
        return
    end

    if battleMode == "ignore" then
        AcquireNextTargetOrFallback(GUARD_ST, "tatica ignore")
        return
    end

    local attackRange = GetV(V_ATTACKRANGE, MyID) or 1
    local targetDistance = DistRect(MyID, MyEnemy)
    if targetDistance < LastObservedTargetDistance then
        LastObservedTargetDistance = targetDistance
        LastTargetProgress = GetTick()
    end

    if targetDistance > attackRange and GetTick() >= LastTargetProgress + (Config.TargetTimeout or 3000) then
        LastObservedTargetDistance = 999
        AcquireNextTargetOrFallback(GetReturnState(owner), "target timeout")
        return
    end

    if targetDistance > attackRange then
        if MoveTowardTarget(MyEnemy, attackRange) then
            Logger.debug("CHASE alvo id=" .. tostring(MyEnemy) .. " dist=" .. tostring(targetDistance))
        end
        return
    end

    if battleMode == "skills_only" then
        if GetTick() < LastSkillTry + (settings.skill_interval or 1200) then
            return
        end

        if TryUseConfiguredSkill(settings, MyEnemy, owner) then
            return
        end
        return
    end

    if battleMode == "basic_with_skills" then
        if AttackedSinceLastSkill and GetTick() >= LastSkillTry + (settings.skill_interval or 1200) then
            if TryUseConfiguredSkill(settings, MyEnemy, owner) then
                LastTargetProgress = GetTick()
                LastObservedTargetDistance = targetDistance
                return
            end
        end

        if GetTick() < LastAttackCommand + BASIC_ATTACK_RETRY_INTERVAL then
            return
        end

        LastAttackCommand = GetTick()
        Attack(MyID, MyEnemy)
        AttackedSinceLastSkill = true
        LastTargetProgress = LastAttackCommand
        LastObservedTargetDistance = targetDistance
        Logger.debug("ATTACK comando basico id=" .. tostring(MyEnemy))
        TryDanceAttack(settings, MyEnemy)
        return
    end

    if GetTick() < LastAttackCommand + BASIC_ATTACK_RETRY_INTERVAL then
        return
    end

    LastAttackCommand = GetTick()
    Attack(MyID, MyEnemy)
    LastTargetProgress = LastAttackCommand
    LastObservedTargetDistance = targetDistance
    Logger.debug("ATTACK comando basico id=" .. tostring(MyEnemy))
    TryDanceAttack(settings, MyEnemy)
end

-- ------------------------------------------------------------
-- Ponto de entrada — chamado a cada tick pelo cliente RO
-- ------------------------------------------------------------

function AI(id)
    MyID = id
    if GetTick() < MyStart + Config.SpawnDelay then return end

    if     MyState == GUARD_ST  then OnGUARD()
    elseif MyState == FOLLOW_ST then OnFOLLOW()
    elseif MyState == ATTACK_ST then OnATTACK()
    elseif MyState == MOVE_CMD_ST then OnMOVE_CMD_ST()
    end
end

-- ------------------------------------------------------------
-- Comandos do jogador
-- ------------------------------------------------------------

function OnATTACK_OBJECT_CMD(targetID)
    return
end

function OnMOVE_CMD(x, y)
    return
end

function OnSTOP_CMD()
    return
end

function OnFOLLOW_CMD()
    return
end

function OnSTAND_BY_CMD()
    return
end
