local startTime = os.time()
DogMetrics:NewGauge( "cfc.server.sessionTime", "seconds", 1, function()
    return os.time() - startTime
end )
