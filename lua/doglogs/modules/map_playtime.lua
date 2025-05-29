local message = "Lua shutdown! The map was %s, with a session time of %d seconds."
local startTime = os.time()

hook.Add( "ShutDown", "DogLogs_MapPlaytime", function()
    local log = string.format( message, game.GetMap(), math.Round( os.time() - startTime ) )
    DogLogs.Log( log )
end )
