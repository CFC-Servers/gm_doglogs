-- Records the PhysEnv's simulation time

local physenv_GetLastSimulationTime = physenv.GetLastSimulationTime
local Deque = include( "doglogs/utils/deque.lua" )

local Tracker = DogMetrics:NewMetric( {
    name = "cfc.server.physenv.simulationTime",
    unit = "seconds",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Gauge
} )

local windowSize = 10
local currentTotal = 0

-- Prefill the queue
local queue = Deque() do
    local default = engine.TickInterval()
    currentTotal = default * windowSize

    for _ = 1, windowSize do
        queue.Push( default )
    end
end

local i = 0
hook.Add( "Tick", "DogMetrics_ServerSimulationTime", function()
    local simulationTime = physenv_GetLastSimulationTime()

    local oldest = queue.Pop()
    queue.Push( simulationTime )

    currentTotal = currentTotal + simulationTime - oldest

    i = i + 1
    if i >= windowSize then
        Tracker:AddPoint( currentTotal / windowSize )
        i = 0
    end
end )
