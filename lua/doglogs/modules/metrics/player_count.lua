DogMetrics:NewMetric( {
    name = "cfc.server.players.total",
    unit = "player",
    interval = 1,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return #player.GetHumans()
    end
} )

local AFKTracker = DogMetrics:NewMetric( {
    name = "cfc.server.players.afk",
    unit = "player",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local SentinelTracker = DogMetrics:NewMetric( {
    name = "cfc.server.players.sentinel",
    unit = "player",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local ModeratorTracker = DogMetrics:NewMetric( {
    name = "cfc.server.players.moderator",
    unit = "player",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local AdminTracker = DogMetrics:NewMetric( {
    name = "cfc.server.players.admin",
    unit = "player",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
} )

local function isAdmin( ply )
    return ply:IsAdmin() or ply:IsSuperAdmin()
end

timer.Create( "DogMetrics_PlayerCountTracker", 5, 0, function()
    local afkCount = 0
    local sentinelCount = 0 
    local moderatorCount = 0
    local adminCount = 0

    local humans = player.GetHumans()

    for _, ply in ipairs( humans ) do
        local isAFK = ply:GetNWBool( "CFC_AntiAFK_IsAFK", false )
        if isAFK then afkCount = afkCount + 1 end

        local userGroup = ply:GetUserGroup()
        if userGroup == "sentinel" then
            sentinelCount = sentinelCount + 1
        elseif userGroup == "moderator" then
            moderatorCount = moderatorCount + 1
        elseif isAdmin( ply ) then
            adminCount = adminCount + 1
        end
    end

    AFKTracker:AddPoint( afkCount )
    SentinelTracker:AddPoint( sentinelCount )
    ModeratorTracker:AddPoint( moderatorCount )
    AdminTracker:AddPoint( adminCount )
end )
