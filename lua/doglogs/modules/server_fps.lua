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
local frameQueue = Deque() do
    local targetFps = 1 / engine.TickInterval()
    currentTotal = targetFps * windowSize

    for _ = 1, windowSize do
        frameQueue:Push( targetFps )
    end
end

local i = 0
hook.Add( "Think", "DogMetrics_ServerFPS", function()
    local fps = 1 / FrameTime()

    local oldestFps = frameQueue:Pop()
    frameQueue:Push( fps )

    currentTotal = currentTotal + fps - oldestFps

    i = i + 1
    if i >= windowSize then
        tracker:AddPoint( currentTotal / windowSize )
        i = 0
    end
end )
