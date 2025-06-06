local function ping()
    local pingData = {
        received = os.time(),
        map = game.GetMap(),
    }

    print( util.TableToJSON( {
        doglogs_ping = pingData
    } ) )
end

concommand.Add( "doglogs_ping", ping )
timer.Create( "DogLogs_Ping", 30, 0, ping )
