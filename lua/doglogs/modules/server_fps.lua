-- Records the Server's FPS as a rate metric

DogMetrics:NewMetric( {
    name = "server.fps3",
    unit = "frame",
    interval = 1,
    metricType = DogMetrics.MetricTypes.rate,
    measureFunc = function()
        return 1 / FrameTime()
    end
} )
