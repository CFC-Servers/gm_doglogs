--- @diagnostic disable-next-line: param-type-mismatch
local apiKey = CreateConVar( "datadog_api_key", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "API key for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local hostname = CreateConVar( "datadog_hostname", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Hostname for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local serviceName = CreateConVar( "datadog_service_name", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Service name for DataDog Metrics reporting" )

-- API Ref: https://docs.datadoghq.com/api/latest/metrics/#submit-metrics
-- Ref about Metric Units: https://docs.datadoghq.com/metrics/units/

--- @class DogMetrics
DogMetrics = {
    reportURL = "https://api.datadoghq.com/api/v2/series",
    reportInterval = 10,
    trackers = {}
}

--- @enum DogMetrics_MetricTypes
DogMetrics.MetricTypes = {
    unspecified = 0,
    count = 1,
    rate = 2,
    gauge = 3
}

--- @param name string The name of the metric
--- @param unit string The unit of the metric (e.g., "ms", "bytes", etc.)
--- @param interval number The interval in seconds at which the metric should be reported
--- @param metricType DogMetrics_MetricTypes The type of the metric
--- @param cb fun(): number Callback function that will be called with the tracker object
--- @return DogMetrics_Tracker The tracker object that can be used to add points to the metric
function DogMetrics:NewMetric( name, unit, interval, metricType, cb )
    local points = {}

    --- @class DogMetrics_Tracker
    local tracker = {
        payload = {
            interval = interval, -- Apparently not needed for the Gauge type
            metric = name,
            type = metricType,
            unit = unit,
            points = points,
            resources = {
                { name = hostname:GetString(), type = "host" },
                { name = serviceName:GetString(), type = "service" }
            }
        }
    }

    --- Adds a point to the tracker's timeseries
    --- @param value number The value to add to the timeseries
    function tracker:AddPoint( value )
        table.insert( points, {
            timestamp = os.time(),
            value = value
        } )
    end

    --- Clears all points from the tracker
    function tracker:ClearPoints()
        points = {}
        self.payload.points = points
    end

    local timerName = "DogMetrics_Tracker_" .. name

    --- Report an error and remove the tracker from the list
    --- @param message string The error message to report
    local function err( message )
        timer.Remove( timerName )
        table.RemoveByValue( self.trackers, tracker )

        error( "Error in metric '" .. name .. "': " .. message, 1 )
    end

    timer.Create( timerName, interval, 0, function()
        local success = ProtectedCall( function()
            local value = cb()

            if not value then
                return err( "Callback for metric '" .. name .. "' returned nil - aborting collection" )
            end

            tracker:AddPoint( value )
        end )

        if not success then
            return err( "Failed to collect metric '" .. name .. "' - aborting collection" )
        end
    end )

    table.insert( self.trackers, tracker )

    return tracker
end

--- Returns a JSON payload suitable for reporting to the DataDog Metrics API
function DogMetrics:GetReportPayload()
    local payload = { series = {} }

    for _, tracker in ipairs( self.trackers ) do
        if #tracker.payload.points > 0 then
            table.insert( payload.series, tracker.payload )
        end
    end

    return payload
end

--- Clears all points from all trackers
function DogMetrics:ClearTrackers()
    for _, tracker in ipairs( self.trackers ) do
        tracker:ClearPoints()
    end
end

--- Reports the collected metrics to the DataDog Metrics API
function DogMetrics:Report()
    if not apiKey:GetString() or apiKey:GetString() == "" then
        print( "DogMetrics: Report aborted - API key is not set" )
        return
    end

    if #self.trackers == 0 then return end

    local payload = self:GetReportPayload()
    local body = util.TableToJSON( payload )

    for _, tracker in ipairs( self.trackers ) do
        tracker:ClearPoints()
    end

    local queued = HTTP( {
        url = self.reportURL,
        method = "POST",
        type = "application/json",
        timeout = 5,
        headers = { ["DD-API-KEY"] = apiKey:GetString() },

        body = body,

        success = function( code, successBody )
            if code ~= 202 then
                error( "Failed to report metrics: HTTP " .. code .. " - " .. successBody )
            end
        end,

        failed = function( reason )
            error( "Failed to report metrics: HTTP " .. reason )
        end
    } )

    if not queued then
        error( "Failed to queue metrics report - HTTP request failed" )
    end
end

timer.Create( "DogMetrics_Report", DogMetrics.reportInterval, 0, function()
    if #DogMetrics.trackers == 0 then return end
    DogMetrics:Report()
end )
