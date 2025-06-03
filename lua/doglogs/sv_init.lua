DogLogs = {}
function DogLogs.Log( str )
    print( str )
end

include( "metrics.lua" )

local modulesPath = "doglogs/modules/"

local function loadDirectory( path )
    local files, dirs = file.Find( path .. "/*.lua", "LUA" )
    for _, v in pairs( files ) do
        local fullPath = path .. "/" .. v
        print( "[DogLogs] Loading module: ", fullPath )
        include( fullPath )
    end

    -- Load subdirectories
    for _, v in pairs( dirs ) do
        loadDirectory( path .. "/" .. v )
    end
end

loadDirectory( modulesPath )
