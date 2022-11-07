local os_time = os.time
local rawset = rawset
local table_insert = table.insert
local util_TableToJSON = util.TableToJSON

DogStats._modules = {}
local modules = DogStats._modules

local apiKey = DogStats._apiKey:GetString()
local interval = DogStats._interval:GetInt()
local hostName = DogStats._hostName:GetString()
local serviceName = DogStats._serviceName:GetString()

-- Cvar callbacks
do
    cvars.AddChangeCallback( "dogstats_interval", function( _, _, newValue )
        interval = tonumber( newValue )
        timer.Adjust( "dogstats_metrics", interval, 0, function()
            DogStats:SendMetrics()
        end )
    end )

    cvars.AddChangeCallback( "dogstats_hostname", function( _, _, newValue )
        hostName = newValue
    end )

    cvars.AddChangeCallback( "dogstats_servicename", function( _, _, newValue )
        serviceName = newValue
    end )
end


timer.Create( "dogstats_metrics", interval, 0, function()
    DogStats:SendMetrics()
end )

DogStats.MetricTypes = {
    UNSPECIFIED = 0,
    COUNT = 1,
    RATE = 2,
    GAUGE = 3,
}

function DogStats:Register( name, module )
    self._modules[name] = module
end

function DogStats:MakeModule( name )
    local newModule = {}
    newModule.points = {}
    newModule._report = {
        metric = name,
        type = DogStats.MetricTypes.UNSPECIFIED,
        source_type_name = "gmod",
    }

    local points = newModule.points
    local report = newModule._report

    function newModule:SetTags( tags )
        report.tags = tags
    end

    function newModule:SetType( metricType )
        report.type = metricType
    end

    function newModule:SetUnitName( unitName )
        report.unit = unitName
    end

    function newModule:TrackPoint( value )
        local point = { timestamp = os_time(), value = value }
        table_insert( points, point )
    end

    function newModule:Report()
        local reportStruct = table.Copy( report )
        rawset( reportStruct, "points", points )
        rawset( reportStruct, "interval", interval )
        rawset( reportStruct, "resources", {
            {
                type = "service",
                name = serviceName
            },
            {
                type = "host",
                name = hostName
            }
        } )

        rawset( self, "points", {} )
        return reportStruct
    end

    self:Register( name, newModule )
    return newModule
end

local success = function() end
local failed = function( reason )
    error( "Failed to send metrics to DataDog: " .. reason )
end

function DogStats:SendMetrics()
    local headers = {
        ["Content-Type"] = "application/json",
        ["DD-API-KEY"] = apiKey
    }

    local reports = {}
    for _, module in pairs( modules ) do
        table_insert( reports, module:Report() )
    end

    local url = rawget( self, "_apiUrl" )
    local request = util_TableToJSON( { series = reports } )

    -- TableToJSON forces (1) to be 1.0, which DataDog doesn't like
    request = string.gsub( request, "(%d+)%.0([,}])", "%1%2" )

    HTTP( {
        method = "POST",
        url = url,
        body = request,
        failed = failed,
        success = success,
        headers = headers,
        timeout = interval * 0.75,
        type = "application/json"
    } )
end

