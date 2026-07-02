-- ============================================================
-- Metadata
-- Nome: HellpsAI
-- Versao: 1.0
-- ============================================================
-- ============================================================
-- Config.lua -- configuracao geral do Homunculus
-- Tudo que a AI principal usa fora das taticas sai deste arquivo.
-- ============================================================

local Config = {}
local Tactic = _G.Tactic or {}

local function DeepMerge(source, destination)
    if type(source) ~= "table" then return end
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(destination[key]) ~= "table" then
                destination[key] = {}
            end
            DeepMerge(value, destination[key])
        else
            destination[key] = value
        end
    end
end

function GetTactic(mob_id)
    local merged = {}
    DeepMerge(Tactic[0], merged)
    if mob_id ~= 0 and type(Tactic[mob_id]) == "table" then
        DeepMerge(Tactic[mob_id], merged)
    end
    return merged
end

_G.Config = Config
_G.Tactic = Tactic
_G.GetTactic = GetTactic

-- ------------------------------------------------------------
-- Logger
-- ------------------------------------------------------------

-- Liga ou desliga todos os logs.
Config.LogEnabled = false

-- Pasta onde o logger tenta salvar o arquivo.
Config.LogDir = "./AI/USER_AI/logs"

-- ------------------------------------------------------------
-- Identidade do homunculus
-- ------------------------------------------------------------

-- Homunculus base esperado na configuracao global.
Config.HomType = AMISTR

-- Homunculus S esperado na configuracao global.
Config.HomSType = DIETER

-- ------------------------------------------------------------
-- Movimentacao e alcance
-- ------------------------------------------------------------

-- Distancia maxima do dono fora de combate.
Config.FollowDistance = 2

-- Delay inicial apos invocar o homunculus.
Config.SpawnDelay = 1000

-- Area maxima de combate quando o dono esta parado.
Config.LimitAreaStopped = 11

-- Area maxima de combate quando o dono esta em movimento.
Config.LimitAreaFollowing = 9

-- ------------------------------------------------------------
-- Comportamento ocioso
-- ------------------------------------------------------------

-- Ativa o passeio aleatorio quando o dono estiver parado.
Config.IdleWalkEnabled = true

-- SP minimo em porcentagem para passear.
Config.IdleWalkSP = 80

-- Intervalo minimo entre movimentos ociosos.
Config.IdleWalkInterval = 500

-- ------------------------------------------------------------
-- Combate global
-- ------------------------------------------------------------

-- Tempo maximo em ms para insistir no mesmo alvo sem progresso visivel.
Config.TargetTimeout = 3000

-- HP minimo em porcentagem para permitir entrar em combate.
Config.AggroHP = 0

-- SP minimo em porcentagem para permitir entrar em combate.
Config.AggroSP = 0
