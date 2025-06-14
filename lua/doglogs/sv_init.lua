--- @class DogLogs
DogLogs = {
    Log = print
}

DogMetrics = include( "metrics/sv_init.lua" )

local modulesPath = "doglogs/modules"

function DogLogs.Load()
    local function loadDirectory( path )
        local files = file.Find( path .. "/*.lua", "LUA" )
        for _, v in pairs( files ) do
            local fullPath = path .. "/" .. v
            print( "[DogLogs] Loading module: ", fullPath )
            include( fullPath )
        end

        -- Load subdirectories
        local _, dirs = file.Find( path .. "/*", "LUA" )
        for _, v in pairs( dirs ) do
            loadDirectory( path .. "/" .. v )
        end
    end

    loadDirectory( modulesPath )
end

DogLogs.Load()
DogMetrics:Start()
