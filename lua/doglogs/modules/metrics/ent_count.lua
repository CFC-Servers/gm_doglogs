DogMetrics:NewMetric( {
    name = "cfc.server.entCount.total",
    unit = "entity",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return ents.GetCount()
    end
} )


local entMeta = asseret( FindMetaTable( "Entity" ) )
local ent_IsValid = entMeta.IsValid
local ent_GetClass = entMeta.GetClass
local ent_IsNPC = entMeta.IsNPC
local ent_IsNextBot = entMeta.IsNextBot
local ent_GetPhysicsObject = entMeta.GetPhysicsObject

local npcCount = 0
local NPCTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.npc",
    unit = "npc",
    interval = 10,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local propPhysicsCount = 0
local PropPhysicsTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.props.total",
    unit = "prop",
    interval = 10,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local unfrozenPropCount = 0
local UnfrozenTracker = DogMetrics:NewMetric( {
    name = "cfc.server.entCount.props.unfrozen",
    unit = "prop",
    interval = 10,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

timer.Create( "DogMetrics_EntityCounter", 10, 0, function()
    npcCount = 0
    propPhysicsCount = 0
    unfrozenPropCount = 0

    local allEnts = ents.GetAll()
    local entCount = #allEnts

    for i = 1, entCount do
        local ent = allEnts[i]
        if ent_IsNPC( ent ) or ent_IsNextBot( ent ) then
            npcCount = npcCount + 1
        elseif ent_IsValid( ent ) and ent_GetClass() == "prop_physics" then
            propPhysicsCount = propPhysicsCount + 1

            local physObj = ent_GetPhysicsObject( ent )
            if IsValid( physObj ) and not physObj:IsAsleep() then
                unfrozenPropCount = unfrozenPropCount + 1
            end
        end
    end

    NPCTracker:AddPoint( npcCount )
    PropPhysicsTracker:AddPoint( propPhysicsCount )
    UnfrozenTracker:AddPoint( unfrozenPropCount )
end )
