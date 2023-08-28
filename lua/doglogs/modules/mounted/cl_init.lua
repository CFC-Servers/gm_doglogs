local function networkMountedInfo()
    net.Start( "DogLogs_MountedGameInfo" )

    local gameInfos = engine.GetGames()

    -- Count
    net.WriteUInt( #gameInfos, 6 )

    for i, gameInfo in ipairs( engine.GetGames() ) do
        -- Index in engine.GetGames()
        net.WriteUInt( i, 6 )

        -- Installed
        net.WriteBool( gameInfo.installed )

        -- Mounted
        net.WriteBool( gameInfo.mounted )

        -- Owned
        net.WriteBool( gameInfo.owned )
    end

    net.SendToServer()
end

hook.Add( "InitPostEntity", "DogLogs_MountedGameInfo", function()
    timer.Simple( 20, networkMountedInfo )
end )
