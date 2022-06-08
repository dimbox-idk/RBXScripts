local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
--[[
Network Library by 4eyes

The basic concepts of Network Ownership for anyone interested:
1. Parts not network owned by server or another player will be owned by the player closest to it.
2. To retain network ownership, you must be constantly sending physics packets or people may be able to take ownership, as your network is contested when you aren't sending physics packets.

Usage: Put this in your script, run the PartOwnership enable coroutine [ coroutine.resume(Network["PartOwnership"]["Enable"]) ] and use Network.RetainPart(Part) on any part you'd like to retain ownership over, then just apply a replicating method of movement. Network["RemovePart"](Part) to remove ownership of a part, and run the PartOwnership Disable coroutine [ coroutine.resume(Network["PartOwnership"]["Disable"]) ] to stop. Credit me if you'd like.

Example script:
loadstring(game:HttpGet("https://raw.githubusercontent.com/your4eyes/RobloxScripts/main/Net_Library.lua"))()
coroutine.resume(Network["PartOwnership"]["Enable"])
--]]
if not getgenv().Network then
	getgenv().Network = {
		BaseParts = {};
		FakeConnections = {};
		Connections = {};
		Output = {
			Enabled = true;
			Send = function(Type,Output,BypassOutput)
				if type(Type) == "function" and (Type == print or Type == warn or Type == error) and type(Output) == "string" and (type(BypassOutput) == "nil" or type(BypassOutput) == "boolean") then
					if Network["Output"].Enabled == true or BypassOutput == true then
						Type("[NETWORK] "..Output);
					end;
				elseif Network["Output"].Enabled == true then
					error("[NETWORK] Output Send Error : Invalid syntax.");
				end;
			end;
		};
	}
	Network["Velocity"] = Vector3.new(17.3205081,17.3205081,17.3205081); --exactly 30 magnitude
	Network["RetainPart"] = function(Part,ReturnFakePart) --function for retaining ownership of unanchored parts
		if Part ~= nil and type(Part) == "userdata" and Part:IsA("BasePart") and (type(ReturnFakePart) == "boolean" or type(ReturnFakePart) == "nil") then
			if Part:IsDescendantOf(workspace) then
				if not table.find(Network["BaseParts"],Part) then
					table.insert(Network["BaseParts"],Part)
					Network["Output"].Send(print,": PartOwnership applied to BasePart "..Part:GetFullName()..".")
					if ReturnFakePart == true then
						return FakePart
					end
				else
					Network["Output"].Send(print,": PartOwnership not applied to BasePart "..Part:GetFullName()..", as it already active.")
				end
			else
				Network["Output"].Send(error,"RetainPart Error : Instance "..tostring(Part).." is not a BasePart or does not exist in workspace.")
			end
		else
			Network["Output"].Send(error,"RetainPart Error : Invalid syntax.")
		end
	end
	Network["RemovePart"] = function(Part) --function for removing ownership of unanchored part
		if Part ~= nil and type(Part) == "userdata" and Part:IsA("BasePart")  then
			if Part:IsA("BasePart") then
				local Index = table.find(Network["BaseParts"],Part)
				if Index then
					table.remove(Network["BaseParts"],Index)
					Network["Output"].Send(print,": PartOwnership removed from part "..Part:GetFullName()..".")
				else
					Network["Output"].Send(warn,"RemovePart Warning : BasePart "..Part:GetFullName().." not found in BaseParts table.")
				end
			else
				Network["Output"].Send(error,"RemovePart Error : Instance "..tostring(Part).." is not a BasePart or does not exist in workspace or in game.")
			end
		else
			Network["Output"].Send(error,"RemovePart Error : Invalid syntax.")
		end
	end
	Network["SuperStepper"] = Instance.new("BindableEvent") --make super fast event to connect to
	for _,Event in pairs({RunService.Stepped,RunService.Heartbeat}) do
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
			Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus = LocalPlayer.ReplicationFocus
			LocalPlayer.ReplicationFocus = workspace
			Network["PartOwnership"]["PreMethodSettings"].SimulationRadius = gethiddenproperty(LocalPlayer,"SimulationRadius")
			Network["PartOwnership"]["Connection"] = Network["SuperStepper"].Event:Connect(function() --super fast asynchronous loop
				sethiddenproperty(LocalPlayer,"SimulationRadius",1/0)
				for _,Part in pairs(Network["BaseParts"]) do --loop through parts and do network stuff
					coroutine.wrap(function()
						if Part:IsDescendantOf(workspace) then
							Part.Velocity = Network["Velocity"]+Vector3.new(0,math.cos(tick()*50),0) --keep network by sending physics packets of 30 magnitude + an everchanging addition in the y level so roblox doesnt get triggered and fuck your ownership
							if not isnetworkowner(Part) then --lag parts my ownership is contesting but dont have network over to spite the people who have ownership of stuff i want >:(
								--Network["Output"].Send(print,": Part "..Part:GetFullName().." is not owned. Contesting ownership...") --you can comment this out if you dont want console spam lol
								sethiddenproperty(Part,"NetworkIsSleeping",true)
							else
								sethiddenproperty(Part,"NetworkIsSleeping",false)
							end
						else
							Network["RemovePart"](Part)
						end
						--[==[ [[by 4eyes btw]] ]==]--
					end)()
				end
			end)
			Network["Output"].Send(print,": PartOwnership enabled.")
		end
	end)
	Network["PartOwnership"]["Disable"] = coroutine.create(function()
		if Network["PartOwnership"]["Connection"] then
			Network["PartOwnership"]["Connection"]:Disconnect()
			LocalPlayer.ReplicationFocus = Network["PartOwnership"]["PreMethodSettings"].ReplicationFocus
			sethiddenproperty(LocalPlayer,"SimulationRadius",Network["PartOwnership"]["PreMethodSettings"].SimulationRadius)
			Network["PartOwnership"]["PreMethodSettings"] = {}
			for _,Part in pairs(Network["BaseParts"]) do
				Network["RemovePart"](Part)
			end
			Network["PartOwnership"]["Enabled"] = false
			Network["Output"].Send(print,": PartOwnership disabled.")
		end
	end)
end
