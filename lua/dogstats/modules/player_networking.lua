local rawget = rawget
local player_GetAll = player.GetAll

local Ping = DogStats:MakeModule( "game.players.ping" )
Ping:SetType( DogStats.MetricTypes.COUNT )
Ping:SetUnitName( "ms" )

local PacketLoss = DogStats:MakeModule( "game.players.loss" )
PacketLoss:SetType( DogStats.MetricTypes.COUNT )
PacketLoss:SetUnitName( "lost packets" )

timer.Create( "DogStats_PlyNetworking", 1, 0, function()
    local totalLoss = 0
    local totalPing = 0

    local players = player_GetAll()
    local playerCount = #players

    for i = 1, playerCount do
        local ply = rawget( players, i )

        totalPing = totalPing + ply:Ping()
        totalLoss = totalLoss + ply:PacketLoss()
    end

    if playerCount > 0 then
        Ping:TrackPoint( totalPing / playerCount )
        PacketLoss:TrackPoint( totalLoss / playerCount )
    else
        Ping:TrackPoint( 0 )
        PacketLoss:TrackPoint( 0 )
    end
end )
