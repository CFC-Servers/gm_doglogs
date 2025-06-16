DogMetrics:NewGauge( "cfc.server.luaMemory", "kilobyte", 1, function()
    return collectgarbage( "count" )
end )
