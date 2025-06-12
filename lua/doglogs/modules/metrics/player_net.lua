local PingTracker = DogMetrics:NewGauge( "cfc.server.ping.average", "miliseconds" )
local LossTracker = DogMetrics:NewGauge( "cfc.server.packetLoss.average", "percent" )

timer.Create( "DogMetrics_PlayerNetPerformance", 1, 0, function()
    local totalPing = 0
    local totalLoss = 0

    local plys = player.GetHumans()
    local plyCount = #plys

    for _, ply in ipairs( plys ) do
        if IsValid( ply ) and ply:IsConnected() then
            local ping = ply:Ping()
            local loss = ply:PacketLoss()

            totalPing = totalPing + ping
            totalLoss = totalLoss + loss
        end
    end

    local averagePing = plyCount > 0 and totalPing / plyCount or 0
    PingTracker.AddPoint( averagePing )

    local averageLoss = plyCount > 0 and totalLoss / plyCount or 0
    LossTracker.AddPoint( averageLoss )
end )
