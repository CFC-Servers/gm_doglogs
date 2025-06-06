--- @meta

local OldInclude = include

function include( FileName )
    if string.sub( FileName, -4 ) ~= ".lua" then
        FileName = FileName .. ".lua"
    end

    return OldInclude( FileName )
end
