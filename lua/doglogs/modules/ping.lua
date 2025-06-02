local startTime = os.time()
local perPlayerStats = { -- Will track mean, median, q1, q3, min, max.
    packet_loss = function( ply ) return ply:PacketLoss() end,
    ping = function( ply ) return ply:Ping() end,
    afk = function( ply ) return ply:GetNWBool( "CFC_AntiAFK_IsAFK", false ) and 1 or 0 end,
}

local function ping()
    local plys = player.GetHumans()
    local plyCount = #plys
    local pingData = {
        received = os.time(),
        uptime = SysTime(),
        session_time = os.time() - startTime,
        player_count = plyCount,
        map = game.GetMap(),
    }

    -- Collect statistical values for each player stat.
    for key, func in pairs( perPlayerStats ) do
        local tbl = {}
        pingData[key] = tbl

        -- Avoid divide by zero.
        if plyCount == 0 then
            tbl.mean = 0
            tbl.median = 0
            tbl.q1 = 0
            tbl.q3 = 0
            tbl.min = 0
            tbl.max = 0

            continue
        end

        local valTotal = 0
        local vals = {}

        for i, ply in ipairs( plys ) do
            local val = func( ply )
            valTotal = valTotal + val
            vals[i] = val
        end

        table.sort( vals )

        tbl.mean = valTotal / plyCount
        tbl.median = vals[math.ceil( plyCount * 0.5 )]
        tbl.q1 = vals[math.ceil( plyCount * 0.25 )]
        tbl.q3 = vals[math.ceil( plyCount * 0.75 )]
        tbl.min = vals[1]
        tbl.max = vals[plyCount]
    end

    print( util.TableToJSON( {
        doglogs_ping = pingData
    } ) )
end

concommand.Add( "doglogs_ping", ping )
timer.Create( "DogLogs_Ping", 30, 0, ping )
