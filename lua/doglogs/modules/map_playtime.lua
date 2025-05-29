local message = "DogLogs_MapPlayime: The previous map was %s, with a session time of %d seconds."
local fileName = "cfc_doglogs_map_playtime.json"
local startTime = os.time()

-- Log the previous session's data, and remove the file.
if file.Exists( fileName, "DATA" ) then
    local info = util.JSONToTable( file.Read( fileName, "DATA" ) )
    local log = string.format( message, info.map, math.Round( info.session_time ) )
    DogLogs.Log( log )

    file.Delete( fileName, "DATA" )
end

-- Write to a file on shutdown and every minute, so crashes don't lose data.
local function updateTracker()
    file.Write( fileName, util.TableToJSON( { map = game.GetMap(), session_time = os.time() - startTime } ) )
end

timer.Create( "DogLogs_MapPlaytime", 60, 1, updateTracker )
hook.Add( "ShutDown", "DogLogs_MapPlaytime", updateTracker )
