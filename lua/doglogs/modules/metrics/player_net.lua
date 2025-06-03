local PingTracker = DogMetrics:NewMetric( {
    name = "cfc.server.ping.average",
    unit = "milliseconds",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local LossTracker = DogMetrics:NewMetric( {
    name = "cfc.server.packetLoss.average",
    unit = "percent",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

timer.Create( "DogMetrics_PlayerNetPerformance", 1, 0, function()
    local totalPing = 0
    local totalLoss = 0

    local plys = player.GetHumans()
    local plyCount = #plys

    for _, ply in ipairs( plys ) do
        if IsValid( ply ) and ply:IsConnected() then
            local ping = ply:Ping()
            local loss = ply:GetPacketLoss()

            totalPing = totalPing + ping
            totalLoss = totalLoss + loss
        end
    end

    local averagePing = plyCount > 0 and totalPing / plyCount or 0
    PingTracker:AddPoint( averagePing )

    local averageLoss = plyCount > 0 and totalLoss / plyCount or 0
    LossTracker:AddPoint( averageLoss )
end )
