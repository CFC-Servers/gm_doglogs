--- @diagnostic disable-next-line: param-type-mismatch
local apiKey = CreateConVar( "datadog_api_key", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "API key for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local hostname = CreateConVar( "datadog_hostname", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Hostname for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local serviceName = CreateConVar( "datadog_service_name", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Service name for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local reportInterval = CreateConVar( "datadog_report_interval", 10, { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Interval in seconds to report metrics to DataDog" )

-- API Ref: https://docs.datadoghq.com/api/latest/metrics/#submit-metrics
-- Ref about Metric Units: https://docs.datadoghq.com/metrics/units/

--- @class DogMetrics
DogMetrics = {
    reportURL = "https://api.datadoghq.com/api/v2/series",
    trackers = {}
}

--- @enum DogMetrics_MetricTypes
DogMetrics.MetricTypes = {
    Unspecified = 0,
    Count = 1,
    Rate = 2,
    Gauge = 3
}

--- @class DogMetrics_NewMetricParams
--- @field name string The name of the metric
--- @field unit string The unit of the metric (e.g., "ms", "bytes", etc.)
--- @field interval number The interval in seconds at which the metric should be reported
--- @field metricType DogMetrics_MetricTypes The type of the metric
--- @field measureFunc? fun(): number Callback function that will be called with the tracker object - returns the value to add to the metric

--- Creates a new metric tracker
--- @param struct DogMetrics_NewMetricParams The parameters for the new metric
--- @return DogMetrics_Tracker The tracker object that can be used to add points to the metric
function DogMetrics:NewMetric( struct )
    local name = assert( struct.name, "Metric name is required" )
    local unit = assert( struct.unit, "Metric unit is required" )
    local interval = assert( struct.interval, "Metric interval is required" )
    local metricType = assert( struct.metricType, "Metric type is required" )
    local cb = struct.measureFunc

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
                { name = "gmod", type = "source" },
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

    -- If no callback is provided, we expect them to be using the tracker:AddPoint method directly at their own discretion
    if cb then
        timer.Create( timerName, interval, 0, function()
            local success = ProtectedCall( function()
                local value = cb()

                -- TODO: Some day we may want to allow them to return nil
                if not value then
                    return err( "Callback for metric '" .. name .. "' returned nil - aborting collection" )
                end

                tracker:AddPoint( value )
            end )

            if not success then
                return err( "Failed to collect metric '" .. name .. "' - aborting collection" )
            end
        end )
    end

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
        parameters = nil,

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

timer.Create( "DogMetrics_Report", reportInterval:GetFloat(), 0, function()
    if #DogMetrics.trackers == 0 then return end
    DogMetrics:Report()
end )

hook.Add( "ShutDown", "DogMetrics_ShutDown", function()
    DogMetrics:Report()
end )

cvars.AddChangeCallback( "datadog_report_interval", function( _, _, newValue )
    local newInterval = tonumber( newValue )
    if not newInterval or newInterval <= 0 then
        print( "DogMetrics: Invalid report interval - must be a positive number" )
        return
    end

    timer.Adjust( "DogMetrics_Report", newInterval )
    print( "DogMetrics: Report interval changed to " .. newInterval .. " seconds" )
end, "DogMetrics_Report_Interval_Change" )
