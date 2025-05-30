local fileName = "cfc_doglogs_map_playtime.json"
local startTime = os.time()

-- Log the previous session's data, and remove the file.
if file.Exists( fileName, "DATA" ) then
    DogLogs.Log( file.Read( fileName, "DATA" ) )

    file.Delete( fileName, "DATA" )
end

-- Write to a file on shutdown and every minute, so crashes don't lose data.
local function updateTracker()
    file.Write( fileName, util.TableToJSON( {
        map_playtime = {
            map = game.GetMap(),
            time = os.time() - startTime,
        }
    } ) )
end

timer.Create( "DogLogs_MapPlaytime", 60, 1, updateTracker )
hook.Add( "ShutDown", "DogLogs_MapPlaytime", updateTracker )
