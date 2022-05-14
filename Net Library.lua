--[[
Network Library by 4eyes
Usage: Put this in your script and use Network.RetainPart(Part) on any part you'd like to retain ownership over, then just apply a replicating method of movement. Credit me if you'd like.
--]]
local Players = game:GetService("Players") --define variables n shit
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
if not getrenv().Network then
	getrenv().Network = {}
	Network["BaseParts"] = {}
	Network["RetainPart"] = function(Part) --function for retaining ownership of unanchored parts
		if Part:IsA("BasePart") and isnetworkowner(Part) then
			local CParts = Part:GetConnectedParts()
			for _,CPart in pairs(CParts) do --check if part is connected to anything already in baseparts being retained
				if table.find(Network["BaseParts"],CPart) then
					print("Did not apply PartOwnership to part, as it is already connected to a part with this method active.") 
					return
				end
			end
			table.insert(Network["BaseParts"],Part)
		end
	end
	Network["SuperStepper"] = Instance.new("BindableEvent") --make super fast event to connect to
	game:DefineFastFlag("NewRunServiceSignals",true)
	for _,Event in pairs({RunService.RenderStepped,RunService.Heartbeat,RunService.Stepped,RunService.PreSimulation,RunService.PostSimulation}) do
		Event:Connect(function()
			return Network["SuperStepper"]:Fire(Network["SuperStepper"],tick())
		end)
	end
	Network["PartOwnership"] = {}
	Network["PartOwnership"]["Enabled"] = false
	Network["PartOwnership"]["Execute"] = coroutine.create(function() --creating a thread for network stuff
		if Network["PartOwnership"]["Enabled"] == false then
			Network["PartOwnership"]["Enabled"] = true --do cool network stuff before doing more cool network stuff
			setscriptable(workspace,"StreamingTargetRadius",true)
			setscriptable(workspace,"PhysicsSteppingMethod",true)
			setscriptable(workspace,"StreamingMinRadius",true)
			setscriptable(workspace,"StreamOutBehavior",true)
			settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
			workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
			workspace.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Fixed
			workspace.StreamOutBehavior = Enum.StreamOutBehavior.Opportunistic
			sethiddenproperty(LocalPlayer,"MaximumSimulationRadius",1/0)
			workspace.StreamingTargetRadius = 1/0
			settings().Physics.AllowSleep = false
			workspace.StreamingMinRadius = 1/0
			workspace.StreamingEnabled = true
			Network["SuperStepper"].Event:Connect(function() --super fast asynchronous loop
				sethiddenproperty(LocalPlayer,"SimulationRadius",1/0)
				for _,Part in pairs(Network["BaseParts"]) do --loop through parts and do network stuff
					coroutine.wrap(function()
						Part.Velocity = Vector3.new(14.465,14.465,14.465)
						sethiddenproperty(Part,"NetworkIsSleeping",false)
						LocalPlayer.ReplicationFocus = Part
						--[==[ [[by 4eyes btw]] ]==]
					end)()
				end
			end)
		end
	end)
	coroutine.resume(Network["PartOwnership"]["Execute"])
end
