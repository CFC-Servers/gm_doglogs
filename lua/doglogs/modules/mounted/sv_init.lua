util.AddNetworkString( "DogLogs_MountedGameInfo" )


local gameInfos = engine.GetGames()
net.Receive( "DogLogs_MountedGameInfo", function( _, ply )
    local gameInfo = {}
    local count = net.ReadUInt( 6 )

    for _ = 1, count do
        local idx = net.ReadUInt( 6 )
        local installed = net.ReadBool()
        local mounted = net.ReadBool()
        local owned = net.ReadBool()

        gameInfo[gameInfos[idx].title] = {
            installed = installed,
            mounted = mounted,
            owned = owned
        }
    end

    local json = util.TableToJSON( gameInfo )

    print( "MOUNTED_GAME_INFO - " .. ply:SteamID() .. " - " .. json )
end )
