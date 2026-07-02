-----------------------------
-- Metadata
-- Nome: HellpsAI
-- Versao: 1.0
-----------------------------
-- Dr. Azzy's Mercenary AI
-- Written by Dr. Azzy of iRO Loki
-- Permission granted to distribute in unmodified form
-- Please contact me via the iRO Forums if you wish to modify
-- so that we can work together to extend and improve this AI.
-----------------------------
Version="1.56" 
ErrorCode=""
ErrorInfo=""
LastSavedDate=""
TactLastSavedDate=""
TypeString="M"
dofile( "./AI/USER_AI/Const_.lua")
dofile( "./AI/USER_AI/M_SkillList.lua" )
dofile( "./AI/USER_AI/Defaults.lua")
dofile( "./AI/USER_AI/AzzyUtil.lua")
dofile( "./AI/USER_AI/Stubs.lua")
dofile( "./AI/USER_AI/A_Friends.lua")
dofile( "./AI/USER_AI/M_Config.lua")
dofile( "./AI/USER_AI/M_Tactics.lua")
pcall(function () dofile( "./AI/USER_AI/Mob_ID.lua") end)
dofile( "./AI/USER_AI/AI_main.lua")
dofile( "./AI/USER_AI/M_PVP_Tact.lua")
dofile( "./AI/USER_AI/M_Extra.lua")


function WriteStartupLog(Version,ErrorCode,ErrorInfo)
	local verspattern="%d.%d%d"
	OutFile=io.open("AAIStartM.txt","w")
-- Versão mínima do AI_M mantida apenas para carregar o logger
Version = "1.56"
TypeString = "M"

-- Carrega apenas o logger
local ok, LoggerModule = pcall(dofile, "./Logger.lua")
local Logger = nil
if ok and type(LoggerModule) == "table" then
	Logger = LoggerModule
elseif type(_G.Logger) == "table" then
	Logger = _G.Logger
end

if not Logger then
	Logger = {}
	local fallback_path = "./AAI.log"
	local function fwrite(level, msg)
		local t = os.date("%H:%M")
		local d = os.date("%d/%m/%Y")
		local line = string.format("[%s] [%s] [%s] %s\n", t, d, level, tostring(msg))
		local f = io.open(fallback_path, "a")
		if f then f:write(line); f:close() end
	end
	function Logger.init(opts) fwrite("info", "fallback logger initialized") end
	function Logger.info(m) fwrite("info", m) end
	function Logger.debug(m) fwrite("debug", m) end
	function Logger.warning(m) fwrite("warning", m) end
	function Logger.error(m) fwrite("error", m) end
	function Logger.critical(m) fwrite("critical", m) end
end

pcall(function()
	if type(Logger.init) == "function" then Logger.init({ enabled = true, dir = "./logs" }) end
end)

local function ScanAndLog_M()
	local status, err = xpcall(function()
		local hID = MyID or 0
		local ownerID = 0
		if hID ~= 0 and GetV then ownerID = GetV(V_OWNER, hID) or 0 end

		local pName = "unknown"; local pHP = "NA"; local pSP = "NA"
		if ownerID ~= 0 then
			if GetV then pHP = tostring(GetV(V_HP, ownerID) or "NA") ; pSP = tostring(GetV(V_SP, ownerID) or "NA") end
			if Actors and Actors[ownerID] and Actors[ownerID].Name then pName = tostring(Actors[ownerID].Name) end
		end

		local hName = "unknown"; local hHP = "NA"; local hSP = "NA"; local hType = "NA"
		if hID ~= 0 then
			if GetV then hHP = tostring(GetV(V_HP, hID) or "NA") ; hSP = tostring(GetV(V_SP, hID) or "NA") ; hType = tostring(GetV(V_MERTYPE, hID) or "NA") end
			if Actors and Actors[hID] and Actors[hID].Name then hName = tostring(Actors[hID].Name) end
		end

		local msg = string.format("Player: %s (ID:%s) HP:%s SP:%s | Merc: %s (ID:%s) HP:%s SP:%s Type:%s",
			pName, tostring(ownerID), pHP, pSP, hName, tostring(hID), hHP, hSP, hType)
		if Logger and Logger.info then Logger.info(msg) end
	end, debug and debug.traceback or function(e) return tostring(e) end)
	if not status then
		if Logger and Logger.error then Logger.error("Scan error: "..tostring(err)) end
	end
end

ScanAndLog_M()