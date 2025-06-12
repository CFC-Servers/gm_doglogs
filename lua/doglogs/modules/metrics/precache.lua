if not stringtable then return end

-- Models
local modelPrecache = stringtable.FindTable( "modelprecache" )
DogMetrics:NewGauge( "cfc.server.modelPrecache.size", "vars", 5, function()
    return modelPrecache:GetNumStrings()
end )

-- Sound
local soundPrecache = stringtable.FindTable( "soundprecache" )
DogMetrics:NewGauge( "cfc.server.soundPrecache.size", "vars", 5, function()
    return soundPrecache:GetNumStrings()
end )

-- Decal
local decalPrecache = stringtable.FindTable( "decalprecache" )
DogMetrics:NewGauge( "cfc.server.decalPrecache.size", "vars", 5, function()
    return decalPrecache:GetNumStrings()
end )
