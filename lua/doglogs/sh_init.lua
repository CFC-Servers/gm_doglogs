DogLogs = {}
function DogLogs.Log( str )
    print( str )
end

local moduleBaseDir = "doglogs/modules/"

local function loadModule( moduleDir )
    local path = moduleBaseDir .. moduleDir

    -- Shared
    local shPath = path .. "/sh_init.lua"
    if file.Exists( shPath, "LUA" ) then
        if SERVER then AddCSLuaFile( shPath ) end
        include( shPath )
    end

    -- Server
    local svPath = path .. "/sv_init.lua"
    if SERVER and file.Exists( svPath, "LUA" ) then
        include( svPath )
    end

    -- Client
    local clPath = path .. "/cl_init.lua"
    if file.Exists( clPath, "LUA" ) then
        if SERVER then AddCSLuaFile( clPath ) end
        if CLIENT then include( clPath ) end
    end
end

function DogLogs:LoadModules()
    local _, moduleDirs = file.Find( moduleBaseDir .. "*", "LUA" )

    for _, moduleDir in ipairs( moduleDirs ) do
        loadModule( moduleDir )
    end
end

DogLogs:LoadModules()
