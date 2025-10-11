
--- @type Entity
local entMeta = assert( FindMetaTable( "Entity" ) )
local ent_IsValid = entMeta.IsValid
local ent_GetClass = entMeta.GetClass
local ent_IsConstraint = entMeta.IsConstraint
local ent_GetPhysicsObject = entMeta.GetPhysicsObject

local interval = 10

local TotalTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.total",
    unit = "entity",
    interval = interval,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local npcCount = 0
local NPCTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.npc",
    unit = "npc",
    interval = interval,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local propPhysicsCount = 0
local PropPhysicsTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.props.total",
    unit = "prop",
    interval = interval,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local unfrozenPropCount = 0
local UnfrozenTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.props.unfrozen",
    unit = "prop",
    interval = interval,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local constraintCount = 0
local ConstraintTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.constraint",
    unit = "constraint",
    interval = interval,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

timer.Create( "DogMetrics_EntityCounter", interval, 0, function()
    npcCount = 0
    propPhysicsCount = 0
    unfrozenPropCount = 0
    constraintCount = 0

    local allEnts = ents.GetAll()
    local entCount = #allEnts

    for i = 1, entCount do
        local ent = allEnts[i]
        if ent_IsValid( ent ) then
            if ent:IsNPC() or ent:IsNextBot() then -- These don't work correctly with the Entity metatable
                npcCount = npcCount + 1
            elseif ent_GetClass( ent ) == "prop_physics" then
                propPhysicsCount = propPhysicsCount + 1

                local physObj = ent_GetPhysicsObject( ent )
                if IsValid( physObj ) and not physObj:IsAsleep() then
                    unfrozenPropCount = unfrozenPropCount + 1
                end
            elseif ent_IsConstraint( ent ) then
                constraintCount = constraintCount + 1
            end
        end
    end

    TotalTracker:AddPoint( entCount )
    NPCTracker:AddPoint( npcCount )
    PropPhysicsTracker:AddPoint( propPhysicsCount )
    UnfrozenTracker:AddPoint( unfrozenPropCount )
    ConstraintTracker:AddPoint( constraintCount )
end )
