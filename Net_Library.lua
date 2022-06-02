repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players") --define variables n shit
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Velocity = Vector3.new(30,30,30)
--[[
Network Library by 4eyes
Usage: Put this in your script and use Network.RetainPart(Part) on any part you'd like to retain ownership over, then just apply a replicating method of movement. Credit me if you'd like.
loadstring(game:HttpGet("https://raw.githubusercontent.com/your4eyes/RobloxScripts/main/Net_Library.lua"))()
--]]
if not getgenv().Network then
	getgenv().Network = {}
	Network["BaseParts"] = {}
	Network["Velocity"] = Velocity
	Network["RetainPart"] = function(Part) --function for retaining ownership of unanchored parts
		if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) and not isnetworkowner(Part) then
			local CParts = Part:GetConnectedParts()
			for _,CPart in pairs(CParts) do --check if part is connected to anything already in baseparts being retained
				if table.find(Network["BaseParts"],CPart) then
					warn("[NETWORK] Did not apply PartOwnership to part, as it is already connected to a part with this method active.") 
					return
				end
			end
			local BV = Instance.new("BodyVelocity") --create bodyvelocity to apply constant physics packets and retain ownership
			BV.Name = "NetworkRetainer"
			BV.MaxForce = Vector3.new(1/0,1/0,1/0)
			BV.P = 1/0
			BV.Velocity = Network["Velocity"]
			BV.Parent = Part
			table.insert(Network["BaseParts"],Part)
			print("[NETWORK] PartOwnership applied to part"..Part:GetFullName()..".")
		end
	end
	Network["RemovePart"] = function(Part) --function for removing ownership of unanchored part
		if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
			local Index = table.find(Network["BaseParts"],Part)
			if Index then
				table.remove(Network["BaseParts"],Index)
				local Retainer = Part:FindFirstChild("NetworkRetainer")
				if Retainer then
					Retainer:Destroy()
				end
				print("[NETWORK] PartOwnership removed from part "..Part:GetFullName()..".")
			else
				warn("[NETWORK] Part "..Part:GetFullName().." not found in BaseParts table.")
			end
		end
	end)
	Network["SuperStepper"] = Instance.new("BindableEvent") --make super fast event to connect to
	setfflag("NewRunServiceSignals","true")
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
			setscriptable(workspace,"PhysicsSteppingMethod",true)
			setscriptable(workspace,"PhysicsSimulationRateReplicator",true)
			settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
			workspace.PhysicsSimulationRateReplicator = Enum.PhysicsSimulationRate.Fixed240Hz
			workspace.InterpolationThrottling = Enum.InterpolationThrottling.Enabled
			workspace.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Fixed
			settings().Rendering.EagerBulkExecution = true
			settings().Physics.ThrottleAdjustTime = 1/0
			LocalPlayer.ReplicationFocus = workspace
			settings().Physics.DisableCSGv2 = true
			settings().Physics.AllowSleep = false
			settings().Physics.ForceCSGv2 = false
			settings().Physics.UseCSGv2 = false
			Network["SuperStepper"].Event:Connect(function() --super fast asynchronous loop
				sethiddenproperty(LocalPlayer,"SimulationRadius",1/0)
				for i,Part in pairs(Network["BaseParts"]) do --loop through parts and do network stuff
					coroutine.wrap(function()
						if Part:IsDescendantOf(workspace) then
							if not isnetworkowner(Part) then --lag parts my ownership is contesting but dont have network over to spite the people who have ownership of stuff i want >:(
								print("[NETWORK] Part "..Part:GetFullName().." is not owned. Contesting ownership...") --you can comment this out if you dont want console spam lol
								sethiddenproperty(Part,"NetworkIsSleeping",true)
							else
								sethiddenproperty(Part,"NetworkIsSleeping",false)
							end
							if not Part:FindFirstChildOfClass("BodyVelocity") then
								local BV = Instance.new("BodyVelocity") --create bodyvelocity to apply constant physics packets and retain ownership
								BV.Name = "NetworkRetainer"
								BV.MaxForce = Vector3.new(1/0,1/0,1/0)
								BV.P = 1/0
								BV.Velocity = Network["Velocity"]
								BV.Parent = Part
							end
						else
							table.remove(Network["BaseParts"],i)
							local BV = Part:FindFirstChildOfClass("BodyVelocity")
							if BV then
								BV:Destroy()
							end
						end
						--[==[ [[by 4eyes btw]] ]==]--
					end)()
				end
			end)
		end
	end)
	Network["PartOwnership"]["Disable"] = coroutine.create(function()
		--ill do it later bleh
	end)
	coroutine.resume(Network["PartOwnership"]["Execute"])
end
