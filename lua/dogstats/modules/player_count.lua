local player_GetCount = player.GetCount

local PlayerCount = DogStats:MakeModule( "game.players.count" )
PlayerCount:SetType( DogStats.MetricTypes.COUNT )

timer.Create( "DogStats_PlayerCount", 5, 0, function()
    PlayerCount:TrackPoint( player_GetCount() )
end )
