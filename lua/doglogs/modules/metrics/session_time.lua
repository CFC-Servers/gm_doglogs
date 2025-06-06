local startTime = os.time()

DogMetrics:NewMetric( {
    name = "cfc.server.sessionTime",
    unit = "seconds",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return os.time() - startTime
    end
} )
