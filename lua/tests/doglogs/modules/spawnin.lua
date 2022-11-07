return {
    groupName = "InitialSpawn",
    cases = {
        {
            name = "Should create a hook",
            func = function()
                local hookTable = hook.GetTable().PlayerInitialSpawn
                expect( hookTable.DogLogs_SpawnedIn ).to.exist()
            end
        },
        {
            name = "Should log the correct information",
            func = function()
                local ply = {
                    Nick = function() return "Test" end,
                    SteamID = function() return "Test" end
                }

                local expected = "Player 'Test'<Test> has spawned in the server. (was transition: true)"

                local logStub = stub( DogLogs, "Log" ).with( function( message )
                    expect( message ).to.equal( expected )
                end )

                hook.GetTable().PlayerInitialSpawn.DogLogs_SpawnedIn( ply, true )

                expect( logStub ).to.haveBeenCalled()
            end
        }
    }
}
