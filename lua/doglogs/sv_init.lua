DogLogs = {}
function DogLogs.Log( str )
    print( str )
end

include( "metrics.lua" )

local modulesPath = "doglogs/modules/"

local files = file.Find( modulesPath .. "/*.lua", "LUA" )
for _, v in pairs( files ) do
    print( "[DogLogs] Loading module: " .. v )
    include( modulesPath .. "/" .. v )
end
