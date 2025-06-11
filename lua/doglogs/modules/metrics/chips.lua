local interval = 5
local trackers = {}

--- @type Entity
local entMeta = assert( FindMetaTable( "Entity" ) )
local ent_IsValid = entMeta.IsValid

local function makeTracker( class, name, cpuFunc )
    trackers[class] = {
        CountTracker = DogMetrics:NewMetric( {
            name = "cfc.server.chips." .. name .. "Count",
            unit = "chips",
            interval = interval,
            metricType = DogMetrics.MetricTypes.Gauge,
        } ),

        CPUsTracker = DogMetrics:NewMetric( {
            name = "cfc.server.chips." .. name .. "CPUs",
            unit = "microseconds/s",
            interval = interval,
            metricType = DogMetrics.MetricTypes.Rate,
        } ),

        cpuFunc = cpuFunc,
    }
end

makeTracker( "gmod_wire_expression2", "e2", function( ent )
    if ent.error then return 0 end -- Errored e2 chips retain their timebench value despite not actually running code anymore.

    local context = ent.context
    if not context then return 0 end

    return context.timebench or 0
end )

makeTracker( "starfall_processor", "sf", function( ent )
    local instance = ent.instance
    if not instance then return 0 end
    if instance.error then return 0 end -- Ignore errored sf chips as well.
    if instance.cpuQuotaRatio == 0 then return 0 end -- This chip is running 'without ops' and doesn't track CPU usage properly.

    return instance:movingCPUAverage() or 0
end )


timer.Create( "DogMetrics_ChipCounter", interval, 0, function()
    for class, trackerInfo in pairs( trackers ) do
        local count = 0
        local cpuSum = 0
        local cpuFunc = trackerInfo.cpuFunc

        for _, ent in ipairs( ents.FindByClass( class ) ) do
            if ent_IsValid( ent ) then
                count = count + 1
                cpuSum = cpuSum + cpuFunc( ent ) * 1000000 -- Seconds to microseconds
            end
        end

        trackerInfo.CountTracker:AddPoint( count )
        trackerInfo.CPUsTracker:AddPoint( cpuSum )
    end
end )
