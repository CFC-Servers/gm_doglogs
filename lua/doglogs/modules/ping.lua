local startTime = os.time()

local function ping()
    print( util.TableToJSON( {
        doglogs_ping = {
            received = os.time(),
            uptime = SysTime(),
            session_time = os.time() - startTime,
            player_count = #player.GetHumans(),
            map = game.GetMap(),
        }
    } ) )
end

concommand.Add( "doglogs_ping", ping )
timer.Create( "DogLogs_Ping", 30, 0, ping )
