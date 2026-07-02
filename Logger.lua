-- ============================================================
-- Logger.lua -- Logger por nivel com um controle global.
-- ============================================================

local Logger = {}

local LEVEL_FILES = {
    debug = "debug.log",
    info = "info.log",
    warning = "warning.log",
    error = "error.log",
    critical = "critical.log",
}

local config = {
    enabled = true,
    dir = "./logs",
}

local function try_mkdir(dir)
    pcall(function() os.execute(string.format('mkdir "%s"', dir)) end)
    pcall(function() os.execute(string.format('mkdir -p "%s"', dir)) end)
end

local function timestamp()
    local okDate, value = pcall(os.date, "%d/%m/%Y %H:%M:%S")
    if okDate and value then
        return value
    end
    return tostring(GetTick and GetTick() or "?")
end

local function get_level_file(level)
    return LEVEL_FILES[string.lower(tostring(level or "info"))] or LEVEL_FILES.info
end

local function append_line(filepath, line)
    local handle = io.open(filepath, "a")
    if not handle then
        try_mkdir(config.dir)
        handle = io.open(filepath, "a")
    end
    if handle then
        handle:write(line)
        handle:close()
        return true
    end

    local fallbackPath = "./" .. filepath:match("([^/]+)$")
    local fallbackHandle = io.open(fallbackPath, "a")
    if fallbackHandle then
        fallbackHandle:write(line)
        fallbackHandle:close()
        return true
    end

    local rootFallback = io.open("./AAI_fallback.log", "a")
    if rootFallback then
        rootFallback:write(line)
        rootFallback:close()
        return true
    end

    return false
end

function Logger.init(opts)
    if type(opts) == "table" then
        if opts.enabled ~= nil then config.enabled = not not opts.enabled end
        if opts.dir then config.dir = opts.dir end
    end

    if not config.enabled then return end

    try_mkdir(config.dir)
    Logger.info("=== Logger iniciado ===")
end

function Logger.log(level, msg)
    if not config.enabled then return end

    local levelName = string.lower(tostring(level or "info"))
    local filename = get_level_file(levelName)
    local filepath = (config.dir or ".") .. "/" .. filename
    local line = string.format("[%s] [%s] %s\n", timestamp(), levelName, tostring(msg))
    append_line(filepath, line)
end

function Logger.debug(msg)    Logger.log("debug", msg) end
function Logger.info(msg)     Logger.log("info", msg) end
function Logger.warning(msg)  Logger.log("warning", msg) end
function Logger.error(msg)    Logger.log("error", msg) end
function Logger.critical(msg) Logger.log("critical", msg) end

_G.Logger = Logger
return Logger
