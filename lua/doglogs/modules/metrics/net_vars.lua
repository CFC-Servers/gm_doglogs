DogMetrics:NewGauge( "cfc.server.netVars.count", "vars", 10, function()
    local netVarCount = 0

    local netVars = BuildNetworkedVarsTable()
    for _, varTbl in pairs( netVars ) do
        netVarCount = netVarCount + table.Count( varTbl )
    end

    return netVarCount
end )
