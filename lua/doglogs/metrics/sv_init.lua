--- @diagnostic disable-next-line: param-type-mismatch
local apiKey = CreateConVar( "datadog_api_key", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "API key for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local hostname = CreateConVar( "datadog_hostname", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Hostname for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local serviceName = CreateConVar( "datadog_service_name", "", { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Service name for DataDog Metrics reporting" )
--- @diagnostic disable-next-line: param-type-mismatch
local reportInterval = CreateConVar( "datadog_report_interval", 10, { FCVAR_ARCHIVE, FCVAR_PROTECTED }, "Interval in seconds to report metrics to DataDog" )

local NewTracker = include( "tracker.lua" )

-- API Ref: https://docs.datadoghq.com/api/latest/metrics/#submit-metrics
-- Ref about Metric Units: https://docs.datadoghq.com/metrics/units/

--- @class DogMetrics
local DogMetrics = {
    reportURL = "https://api.datadoghq.com/api/v2/series",
    trackers = {}
}

--- @enum DogMetrics_MetricTypes
DogMetrics.MetricTypes = {
    Unspecified = "unspecified",
    Count = "count",
    Rate = "rate",
    Gauge = "gauge"
}

--- Creates a new metric tracker
--- @private
--- @param name string The name of the metric
--- @param unit string The unit of the metric (e.g., "ms", "bytes", etc.)
--- @param metricType DogMetrics_MetricTypes The type of the metric (e.g., Count, Rate, Gauge)
--- @param interval number? The interval in seconds at which the metric should be reported (if omitted, as is the case in Count and Rates, the interval defaults to the reporting interval)
--- @return DogMetrics_Tracker tracker The tracker object that can be used to add points to the metric
function DogMetrics:NewTracker( name, unit, metricType, interval )
    local tracker = NewTracker( {
        name = name,
        unit = unit,
        interval = interval,
        metricType = metricType,
        hostname = hostname:GetString(),
        serviceName = serviceName:GetString()
    } )

    table.insert( self.trackers, tracker )

    return tracker
end

--- Removes the given tracker from the list of trackers
--- @param tracker DogMetrics_Tracker The tracker to remove
function DogMetrics:RemoveTracker( tracker )
    table.RemoveByValue( self.trackers, tracker )
end

--- Creates a new Gauge Tracker
--- A Gauge is a metric that represents a single numerical value that can go up or down
--- When measured, it will report the current value at the time of measurement.
--- By default, it has an internal timer that will query the value each iteration.
--- You may also exclude the measure function and manually call the `AddPoint` method to add values to the gauge.
--- @param name string The name of the gauge
--- @param unit string The unit of the gauge (e.g., "ms", "bytes", etc.)
--- @param interval? number The interval in seconds at which the gauge should be measured (only required if a measure function is provided)
--- @param measure? fun(): number? A function that returns the current value of the gauge
function DogMetrics:NewGauge( name, unit, interval, measure )
    local tracker = self:NewTracker( name, unit, DogMetrics.MetricTypes.Gauge )

    --- If no measure function is provided, we expect the user to manually call `tracker.AddPoint( value )`
    if not measure then return tracker end
    interval = assert( interval, "Metric harvest interval is required for automatic gauges" )

    tracker.Timer( "Gauge_Measure", interval, function()
        local value = measure()
        if value then
            tracker.AddPoint( value )
        else
            -- NOTE: If we ever have a good reason to return nil, we should remove this else block
            tracker.err( "Gauge '" .. name .. "' measure function returned nil" )
        end
    end )

    return tracker
end

do
    --- Utility to create a new generic Counter Tracker
    --- This is appropriate for either "Count" or "Rate" metrics.
    --- @param name string The name of the counter metric
    --- @param unit string The unit of the counter metric (e.g., "requests", "errors", etc.)
    --- @param metricType DogMetrics_MetricTypes The type of the counter metric (either Count or Rate)
    local function createCounterTracker( name, unit, metricType )
        --- @class DogMetrics_CounterTracker : DogMetrics_Tracker
        local tracker = self:NewTracker( name, unit, metricType, reportInterval:GetFloat() )

        --- @type number The current count value
        local count = 0

        --- Increment the count
        --- @param value number? The value to increment the count by (default is 1)
        function tracker.Increment( value )
            if value == nil then value = 1 end
            count = count + value
        end

        function tracker.PreparePoints()
            tracker.AddPoint( count )
            count = 0
        end

        return tracker
    end

    --- Creates a new Count Tracker
    --- Use this for metrics that represent a total count of events in a timeframe, such as the number of requests or errors.
    --- Use the `Increment` method on the returned Tracker object to increment the count.
    --- @param name string The name of the count Metric
    --- @param unit string The unit of the count metric (e.g., "spawns", "chats", etc.)
    function DogMetrics:NewCount( name, unit )
        return createCounterTracker( name, unit, DogMetrics.MetricTypes.Count )
    end

    --- Creates a new Rate Tracker
    --- Use this for metrics that represent a rate of events per timeframe.
    --- Use the `Increment` method on the returned Tracker object to increment the count.
    --- @param name string The name of the rate metric
    --- @param unit string The unit of the rate metric (e.g., "requests", "errors", etc.)
    function DogMetrics:NewRate( name, unit )
        return createCounterTracker( name, unit, DogMetrics.MetricTypes.Rate )
    end
end


--- Returns a JSON payload suitable for reporting to the DataDog Metrics API
function DogMetrics:GetReportPayload()
    local payload = { series = {} }

    for _, tracker in ipairs( self.trackers ) do
        local trackerPayload = tracker:GetPayload()

        if trackerPayload then
            table.insert( payload.series, trackerPayload )
        end
    end

    return payload
end

--- Clears all points from all trackers
function DogMetrics:ClearTrackerPoints()
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

    self:ClearTrackerPoints()

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

function DogMetrics:Start()
    local identifier = SysTime()
    local uniqueName = function( name ) return name .. "_" .. identifier end

    timer.Create( uniqueName( "DogMetrics_Report" ), reportInterval:GetFloat(), 0, function()
        if #DogMetrics.trackers == 0 then return end
        DogMetrics:Report()
    end )

    hook.Add( "ShutDown", uniqueName( "DogMetrics_ShutDown" ), function()
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
    end, uniqueName( "DogMetrics_Report_Interval_Change" ) )
end

return DogMetrics
