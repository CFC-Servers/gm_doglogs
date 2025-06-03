-- Records the PhysEnv's simulation time

local Deque = include( "doglogs/utils/deque.lua" )

local tracker = DogMetrics:NewMetric( {
    name = "cfc.server.physenv.simulation_time",
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
hook.Add( "Think", "DogMetrics_ServerSimulationTime", function()
    local simulationTime = physenv.GetLastSimulationTime()

    local oldest = queue.Pop()
    queue.Push( simulationTime )

    currentTotal = currentTotal + simulationTime - oldest

    i = i + 1
    if i >= windowSize then
        tracker:AddPoint( currentTotal / windowSize )
        i = 0
    end
end )
