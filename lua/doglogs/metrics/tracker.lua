--- @class DogMetrics_NewTrackerParams
--- @field name string The name of the metric
--- @field unit string The unit of the metric (e.g., "ms", "bytes", etc.)
--- @field interval number? The interval in seconds at which the metric should be reported (if omitted, as is the case in Count and Rates, the interal defaults to the reporting interval)
--- @field metricType DogMetrics_MetricTypes The type of the metric
--- @field hostname string The hostname of the server
--- @field serviceName string The name of the service (e.g., "gmod", "serverName", "addonName")

--- @class DogMetrics_Resource
--- @field name string The name of the resource (e.g., "gmod", "serverName", "addonName")
--- @field type string The type of the resource (e.g., "source", "host", "service")

--- Creates a new metric tracker
--- @param struct DogMetrics_NewTrackerParams The parameters for the new tracker
return function( struct )
    local name = assert( struct.name, "Metric name is required" )
    local unit = assert( struct.unit, "Metric unit is required" )
    local metricType = assert( struct.metricType, "Metric type is required" )
    local interval = struct.interval

    --- @type DogMetrics_Point[]
    local points = {}

    --- @type string[] A list of timer names for this tracker
    local timers = {}

    --- @class DogMetrics_TrackerPayload
    local payload = {
        --- @type number? The interval (in seconds) at which this metric should be reported (not used for Gauge types)
        interval = interval,

        --- @type string The name of the metric
        metric = name,

        --- @type DogMetrics_MetricTypes The type of the metric
        type = metricType,

        --- @type string The unit of the metric
        unit = unit,

        --- @type DogMetrics_Point[] The points collected for this metric
        points = points,

        --- @type DogMetrics_Resource[] The resources associated with this metric
        resources = {
            { name = "gmod", type = "source" },
            { name = hostname:GetString(), type = "host" },
            { name = serviceName:GetString(), type = "service" }
        }
    }

    --- @class DogMetrics_Tracker
    local tracker = {
        --- @type DogMetrics_TrackerPayload The payload for the tracker
        payload = payload,

        --- @type string[] The name of the timers associated with this tracker
        timers = timers,
    }

    --- Adds a point to the tracker's timeseries
    --- @param value number The value to add to the timeseries
    function tracker.AddPoint( value )
        --- @class DogMetrics_Point
        local point = {
            --- @type number The timestamp of the point
            timestamp = os.time(),

            --- @type number The value of the point
            value = value
        }

        table.insert( points, point )
    end

    --- Overwrite this function to prepare points immediately before reporting
    --- (i.e. counts will add their current count/rates will report their current count)
    function tracker.PreparePoints()
    end

    --- Prepares and returns the payload for the tracker
    --- @return DogMetrics_TrackerPayload? payload The payload for the tracker, or nil if there are no points to report
    function tracker.GetPayload()
        tracker.PreparePoints()

        -- Don't report if there are no points
        if #points == 0 then return nil end

        return payload
    end

    --- Clears all points from the tracker
    function tracker.ClearPoints()
        points = {}
        payload.points = points
    end

    --- Starts a new timer for the tracker
    --- This is a normal timer that will be automatically cleaned up if the measure function errors, or if tracker.err is called
    --- @param timerName string The name of the timer
    --- @param timerInterval number The interval in seconds at which the timer should run
    --- @param func fun(): nil The function to call each time the timer runs
    function tracker.Timer( timerName, timerInterval, func )
        local time = SysTime()

        timerName = "DogMetrics_Tracker_" .. name .. "_" .. timerName .. "_" .. time
        table.insert( timers, timerName )

        timer.Create( timerName, timerInterval, 0, function()
            local success, err = pcall( func )
            if not success then
                tracker.err( "Timer '" .. name .. "' failed: " .. tostring( err ) )
            end
        end )
    end

    --- Report an error and remove the tracker from the list
    --- @param message string The error message to report
    function tracker.err( message )
        for _, timerName in ipairs( tracker.timers ) do
            timer.Remove( timerName )
        end

        DogMetrics:RemoveTracker( tracker )

        error( "Error in metric '" .. name .. "': " .. message, 1 )
    end

    return tracker
end
