-- Records the Server's FPS as a rate metric

local Deque = include( "doglogs/utils/deque.lua" )

local tracker = DogMetrics:NewMetric( {
    name = "cfc.server.fps",
    unit = "frame",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Rate
} )

local windowSize = 10
local currentTotal = 0

-- Prefill the queue
local queue = Deque() do
    local targetFps = 1 / engine.TickInterval()
    currentTotal = targetFps * windowSize

    for _ = 1, windowSize do
        queue.Push( targetFps )
    end
end

local i = 0
hook.Add( "Tick", "DogMetrics_ServerFPS", function()
    local fps = 1 / engine.AbsoluteFrameTime()

    local oldest = queue.Pop()
    queue.Push( fps )

    currentTotal = currentTotal + fps - oldest

    i = i + 1
    if i >= windowSize then
        tracker:AddPoint( currentTotal / windowSize )
        i = 0
    end
end )
