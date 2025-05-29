local message = "Lua shutdown! The map was %s, with a session time of %d seconds."

hook.Add( "ShutDown", "DogLogs_MapPlaytime", function()
    local log = string.format( message, game.GetMap(), math.Round( RealTime() ) )
    DogLogs.Log( log )
end )
