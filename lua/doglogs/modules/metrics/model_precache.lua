local precacheCount = 0
hook.Add( "HolyLib:OnModelPrecache", "DogMetrics_TrackModelPrecache", function( _, idx )
    precacheCount = idx
end )

DogMetrics:NewMetric( {
    name = "cfc.server.modelPrecache.size",
    unit = "vars",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return precacheCount
    end
} )
