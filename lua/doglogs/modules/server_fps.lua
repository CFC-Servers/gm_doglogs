-- Records the Server's FPS as a rate metric

DogMetrics:NewMetric( {
    name = "gameserver.fps",
    unit = "frame",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Rate,
    measureFunc = function()
        return 1 / FrameTime()
    end
} )
