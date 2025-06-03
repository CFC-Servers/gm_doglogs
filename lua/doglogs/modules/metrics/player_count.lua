DogMetrics:NewMetric( {
    name = "cfc.server.players.total",
    unit = "player",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return #player.GetHumans()
    end
} )

DogMetrics:NewMetric( {
    name = "cfc.server.players.afk",
    unit = "player",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        local afkCount = 0
        local humans = player.GetHumans()

        for _, ply in ipairs( humans ) do
            local isAFK = ply:GetNWBool( "CFC_AntiAFK_IsAFK", false )
            if isAFK then afkCount = afkCount + 1 end
        end

        return afkCount
    end
} )
