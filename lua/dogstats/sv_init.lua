require( "logger" )

DogStats = {}
DogStats._apiUrl = "https://api.datadoghq.com/api/v2/series"

-- Setup Convars
do
    local convarFlags = FCVAR_ARCHIVE + FCVAR_PROTECTED
    DogStats._interval = CreateConVar(
        "dogstats_interval", "5", convarFlags, "How often to send metrics to DataDog"
    )

    DogStats._apiKey = CreateConVar(
        "dogstats_api_key", "", convarFlags, "The API key for your DataDog account"
    )

    DogStats._hostName = CreateConVar(
        "dogstats_hostname", "dev", convarFlags, "The hostname to report to DataDog"
    )

    DogStats._serviceName = CreateConVar(
        "dogstats_servicename", "gmod", convarFlags, "The service name to report to DataDog"
    )
end

include( "modules.lua" )

local modulesPath = "dogstats/modules/"

local files = file.Find( modulesPath .. "/*.lua", "LUA" )
for _, v in pairs( files ) do
    print( "[DogStats] Loading module: " .. v )
    include( modulesPath .. "/" .. v )
end
