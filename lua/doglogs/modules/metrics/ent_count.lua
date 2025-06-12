DogMetrics:NewGauge( "cfc.server.entCount.total", "entities", 5, function()
    return ents.GetCount()
end )

--- @type Entity
local entMeta = assert( FindMetaTable( "Entity" ) )
local ent_IsValid = entMeta.IsValid
local ent_GetClass = entMeta.GetClass
local ent_IsNPC = entMeta.IsNPC
local ent_IsNextBot = entMeta.IsNextBot
local ent_IsConstraint = entMeta.IsConstraint
local ent_GetPhysicsObject = entMeta.GetPhysicsObject

local interval = 10

local npcCount = 0
local NPCTracker = DogMetrics:NewGauge( "cfc.server.entCount.npc", "npcs" )

local propPhysicsCount = 0
local PropPhysicsTracker = DogMetrics:NewGauge( "cfc.server.entCount.props.total", "props" )

local unfrozenPropCount = 0
local UnfrozenTracker = DogMetrics:NewGauge( "cfc.server.entCount.props.unfrozen", "prop" )

local constraintCount = 0
local ConstraintTracker = DogMetrics:NewGauge( "cfc.server.entCount.constraints", "constraints" )

timer.Create( "DogMetrics_EntityCounter", interval, 0, function()
    npcCount = 0
    propPhysicsCount = 0
    unfrozenPropCount = 0
    constraintCount = 0

    local allEnts = ents.GetAll()
    local entCount = #allEnts

    for i = 1, entCount do
        local ent = allEnts[i]
        if ent_IsNPC( ent ) or ent_IsNextBot( ent ) then
            npcCount = npcCount + 1
        elseif ent_IsValid( ent ) then
            if ent_GetClass( ent ) == "prop_physics" then
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

    NPCTracker.AddPoint( npcCount )
    PropPhysicsTracker.AddPoint( propPhysicsCount )
    UnfrozenTracker.AddPoint( unfrozenPropCount )
    ConstraintTracker.AddPoint( constraintCount )
end )
