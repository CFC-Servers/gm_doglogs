--- @type GLuaTest_TestGroup
return {
    groupName = "DogLogs:Metrics",

    cases = {
        {
            name = "Initializes correctly",
            func = function()
                expect( GetConVar( "datadog_api_key" ) ).to.exist()
                expect( GetConVar( "datadog_hostname" ) ).to.exist()
                expect( GetConVar( "datadog_service_name" ) ).to.exist()
                expect( GetConVar( "datadog_report_interval" ) ).to.exist()

                expect( DogLogs.Metrics ).to.beA( "table" )
            end
        }
    }
}
