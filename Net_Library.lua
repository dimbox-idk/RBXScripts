repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players") --define variables n shit
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Velocity = Vector3.new(30,30,30)
--[[
Network Library by 4eyes

The basic concepts of Network Ownership for anyone interested:
1. Parts not network owned by server or another player will be owned by the player closest to it.
2. To retain network ownership, you must be constantly sending physics packets or people may be able to take ownership, as your network is contested when you aren't sending physics packets.

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
	end
	Network["SuperStepper"] = Instance.new("BindableEvent") --make super fast event to connect to
	setfflag("NewRunServiceSignals","true")
	for _,Event in pairs({RunService.RenderStepped,RunService.Heartbeat,RunService.Stepped,RunService.PreSimulation,RunService.PostSimulation}) do
		Event:Connect(function()
			return Network["SuperStepper"]:Fire(Network["SuperStepper"],tick())
		end)
	end
	Network["PartOwnership"] = {}
	Network["PartOwnership"]["PreMethodSettings"] = {}
	Network["PartOwnership"]["Enabled"] = false
	Network["PartOwnership"]["Enable"] = coroutine.create(function() --creating a thread for network stuff
		if Network["PartOwnership"]["Enabled"] == false then
			Network["PartOwnership"]["Enabled"] = true --do cool network stuff before doing more cool network stuff
			setscriptable(workspace,"PhysicsSteppingMethod",true)
			setscriptable(workspace,"PhysicsSimulationRateReplicator",true)
			Network["PartOwnership"]["PreMethodSettings"].PhysicsEnvironmentalThrottle = settings().Physics.PhysicsEnvironmentalThrottle
			settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
			Network["PartOwnership"]["PreMethodSettings"].PhysicsSimulationRateReplicator = workspace.PhysicsSimulationRateReplicator
			workspace.PhysicsSimulationRateReplicator = Enum.PhysicsSimulationRate.Fixed240Hz
			Network["PartOwnership"]["PreMethodSettings"].InterpolationThrottling = workspace.InterpolationThrottling
			workspace.InterpolationThrottling = Enum.InterpolationThrottling.Enabled
			Network["PartOwnership"]["PreMethodSettings"].PhysicsSteppingMethod = workspace.PhysicsSteppingMethod
			workspace.PhysicsSteppingMethod = Enum.PhysicsSteppingMethod.Fixed
			setscriptable(workspace,"PhysicsSimulationRateReplicator",false)
			setscriptable(workspace,"PhysicsSteppingMethod",false)
			Network["PartOwnership"]["PreMethodSettings"].EagerBulkExecution = settings().Rendering.EagerBulkExecution
			settings().Rendering.EagerBulkExecution = true
			Network["PartOwnership"]["PreMethodSettings"].ThrottleAdjustTime = settings().Physics.ThrottleAdjustTime
			settings().Physics.ThrottleAdjustTime = 1/0
			Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus = LocalPlayer.ReplicationFocus
			LocalPlayer.ReplicationFocus = workspace
			Network["PartOwnership"]["PreMethodSettings"].DisableCSGv2 = settings().Physics.DisableCSGv2
			settings().Physics.DisableCSGv2 = true
			Network["PartOwnership"]["PreMethodSettings"].AllowSleep = settings().Physics.AllowSleep
			settings().Physics.AllowSleep = false
			Network["PartOwnership"]["PreMethodSettings"].ForceCSGv2 = settings().Physics.ForceCSGv2
			settings().Physics.ForceCSGv2 = false
			Network["PartOwnership"]["PreMethodSettings"].UseCSGv2 = settings().Physics.UseCSGv2
			settings().Physics.UseCSGv2 = false
			Network["PartOwnership"]["PreMethodSettings"].SimulationRadius = gethiddenproperty(LocalPlayer,"SimulationRadius")
			Network["PartOwnership"]["Connection"] = Network["SuperStepper"].Event:Connect(function() --super fast asynchronous loop
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
		if Network["PartOwnership"]["Connection"] then
			Network["PartOwnership"]["Connection"]:Disconnect()
			setscriptable(workspace,"PhysicsSteppingMethod",true)
			setscriptable(workspace,"PhysicsSimulationRateReplicator",true)
			settings().Physics.PhysicsEnvironmentalThrottle = Network["PartOwnership"]["PreMethodSettings"].PhysicsEnvironmentalThrottle
			workspace.PhysicsSimulationRateReplicator = Network["PartOwnership"]["PreMethodSettings"].PhysicsSimulationRateReplicator
			workspace.InterpolationThrottling = Network["PartOwnership"]["PreMethodSettings"].InterpolationThrottling
			workspace.PhysicsSteppingMethod = Network["PartOwnership"]["PreMethodSettings"].PhysicsSteppingMethod
			setscriptable(workspace,"PhysicsSimulationRateReplicator",false)
			setscriptable(workspace,"PhysicsSteppingMethod",false)
			settings().Rendering.EagerBulkExecution = Network["PartOwnership"]["PreMethodSettings"].EagerBulkExecution
			settings().Physics.ThrottleAdjustTime = Network["PartOwnership"]["PreMethodSettings"].ThrottleAdjustTime
			LocalPlayer.ReplicationFocus = Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus
			settings().Physics.DisableCSGv2 = Network["PartOwnership"]["PreMethodSettings"].DisableCSGv2
			settings().Physics.AllowSleep = Network["PartOwnership"]["PreMethodSettings"].AllowSleep
			settings().Physics.ForceCSGv2 = Network["PartOwnership"]["PreMethodSettings"].ForceCSGv2
			settings().Physics.UseCSGv2 = Network["PartOwnership"]["PreMethodSettings"].UseCSGv2settings().Physics.UseCSGv2
			sethiddenproperty(LocalPlayer,"SimulationRadius",Network["PartOwnership"]["PreMethodSettings"].SimulationRadius)
			Network["PartOwnership"]["PreMethodSettings"] = {}
			for _,Part in pairs(Network["BaseParts"]) do
				Network["RemovePart"](Part)
			end
			Network["PartOwnership"]["Enabled"] = false
		end
	end)
	coroutine.resume(Network["PartOwnership"]["Enable"])
end
