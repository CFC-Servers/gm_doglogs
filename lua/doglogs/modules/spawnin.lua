local message = "Player '%s'<%s> has spawned in the server. (was transition: %s)"

hook.Add( "PlayerInitialSpawn", "DogLogs_SpawnedIn", function( ply, transition )
    local log = string.format( message, ply:Nick(), ply:SteamID(), transition )
    DogLogs.Log( log )
end )
