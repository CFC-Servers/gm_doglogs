-- Records the server's Lua memory size

DogMetrics:NewMetric( {
    name = "cfc.server.luaMemory",
    unit = "kilobyte",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Count,
    measureFunc = function()
        return collectgarbage( "count" )
    end
} )
