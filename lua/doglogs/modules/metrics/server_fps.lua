local Tracker = DogMetrics:NewRate( "cfc.server.fps", "frame" )
local Increment = Tracker.Increment

hook.Add( "Tick", "DogMetrics_ServerFPS", Increment )
