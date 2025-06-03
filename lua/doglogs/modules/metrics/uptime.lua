DogMetrics:NewMetric( {
    name = "cfc.server.uptime",
    unit = "seconds",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = SysTime
} )
