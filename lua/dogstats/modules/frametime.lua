local FrameTime = FrameTime

local Module = DogStats:MakeModule( "game.frametime" )
Module:SetType( DogStats.MetricTypes.COUNT )
Module:SetUnitName( "seconds" )

local sampleCount = 0
local totalFrameTime = 0
local targetSampleCount = 66

hook.Add( "Think", "DogStats_FrameTime", function()
    local frameTime = FrameTime()
    totalFrameTime = totalFrameTime + frameTime
    sampleCount = sampleCount + 1

    if sampleCount >= targetSampleCount then
        local averageFrameTime = totalFrameTime / sampleCount
        Module:TrackPoint( averageFrameTime )
        sampleCount = 0
        totalFrameTime = 0
    end
end )
