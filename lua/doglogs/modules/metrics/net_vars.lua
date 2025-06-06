DogMetrics:NewMetric( {
    name = "cfc.server.netVars.total",
    unit = "vars",
    interval = 10,
    metricType = DogMetrics.MetricTypes.Gauge,
    measureFunc = function()
        local netVarCount = 0

        local netVars = BuildNetworkedVarsTable()
        for _, varTbl in pairs( netVars ) do
            netVarCount = netVarCount + table.Count( varTbl )
        end

        return netVarCount
    end
} )
