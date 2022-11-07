-- Find all files in modules/ and include them

DogLogs = {}
function DogLogs.Log( str )
    print( str )
end

local modulesPath = "doglogs/modules/"

local files = file.Find( modulesPath .. "/*.lua", "LUA" )
for _, v in pairs( files ) do
    print( "[DogLogs] Loading module: " .. v )
    include( modulesPath .. "/" .. v )
end
