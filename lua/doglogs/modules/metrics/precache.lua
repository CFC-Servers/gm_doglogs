if not stringtable then return end

-- Models
local modelPrecache = stringtable.FindTable( "modelprecache" )
DogMetrics:NewMetric( {
    name = "cfc.server.modelPrecache.size",
    unit = "vars",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return modelPrecache:GetNumStrings()
    end
} )

-- Generic
local genericPrecache = stringtable.FindTable( "genericprecache" )
DogMetrics:NewMetric( {
    name = "cfc.server.genericPrecache.size",
    unit = "vars",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return genericPrecache:GetNumStrings()
    end
} )

-- Sound
local soundPrecache = stringtable.FindTable( "soundprecache" )
DogMetrics:NewMetric( {
    name = "cfc.server.soundPrecache.size",
    unit = "vars",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return soundPrecache:GetNumStrings()
    end
} )

-- Decal
local decalPrecache = stringtable.FindTable( "decalprecache" )
DogMetrics:NewMetric( {
    name = "cfc.server.decalPrecache.size",
    unit = "vars",
    interval = 5,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        return decalPrecache:GetNumStrings()
    end
} )
