--[[
	Classic Roblox Clothes! 2022
	
	Handles serverside effects such as configuration, collision, etc.
]]
local CollectionService: CollectionService = game:GetService("CollectionService")
local Debris: Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")

local Protocols = ReplicatedStorage:WaitForChild("Protocols")

StarterPlayer.AutoJumpEnabled = false
StarterPlayer.EnableMouseLockOption = false

StarterPlayer.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode.Follow
StarterPlayer.DevTouchCameraMovementMode = Enum.DevTouchCameraMovementMode.Follow
StarterPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse

StarterPlayer.CameraMaxZoomDistance = 358 -- 258

local function fakeCylinderEffect(cylinder: Part): ()	
	cylinder.Shape = Enum.PartType.Ball
	cylinder:SetAttribute("Cylinder", true)
end

local function convertRotate(object : Rotate)
	local convert : Rotate = Instance.new("Rotate")
	convert.Parent = object.Parent
	convert.C0 = object.C0
	convert.C1 = object.C1
	convert.Part0 = object.Part0
	convert.Part1 = object.Part1
	convert.Name = object.Name
	
	object:Destroy()
end

local function createWeld(parent: Instance?, part0: BasePart?, part1: BasePart?): ()
	local weld: WeldConstraint = Instance.new("WeldConstraint")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = parent
end

local function CreateFlagTriangle()
	local FlagTriangle = Instance.new("ImageHandleAdornment")
	FlagTriangle.Name = "FlagTriangle"
	FlagTriangle.Image = "rbxassetid://9018845491"
	FlagTriangle.Size = Vector2.new(2, 3)
end

local function applyControllerFlag(model: Model, color: string): ()
	if model.PrimaryPart ~= nil and model.Parent then
		if not model.Parent:FindFirstChildOfClass("VehicleSeat") then
			local primarypart : Instance? = model.PrimaryPart
			local primaryPosition: Vector3 = model.PrimaryPart.Position

			local _: CFrame, modelSize: Vector3 = model:GetBoundingBox()

			local vehicleSeat: VehicleSeat = Instance.new("VehicleSeat")
			vehicleSeat.BrickColor = BrickColor.new(color)
			vehicleSeat.CanCollide = false
			vehicleSeat.CanQuery = false
			vehicleSeat.CanTouch = false
			vehicleSeat.Locked = true
			vehicleSeat.Transparency = 1
			vehicleSeat.Name = "VS"
			vehicleSeat.Orientation = model.PrimaryPart.Orientation
			vehicleSeat.Position = primaryPosition
			vehicleSeat.Size = model.PrimaryPart.Size
			vehicleSeat.Parent = model

			createWeld(vehicleSeat, vehicleSeat, model.PrimaryPart)
			CollectionService:AddTag(vehicleSeat, "ControllerSeat")

			local triangleNode1: Part = Instance.new("Part")
			triangleNode1.Anchored = false
			triangleNode1.CanCollide = false
			triangleNode1.CanQuery = false
			triangleNode1.CanTouch = false
			triangleNode1.Locked = true
			triangleNode1.Orientation = Vector3.new(0, 90, 90)
			triangleNode1.Position = Vector3.new(primaryPosition.X, modelSize.Y + 0.52, primaryPosition.Z + 1.5)
			triangleNode1.Size = Vector3.new(0.001, 0.001, 0.001)
			triangleNode1.Transparency = 1
			triangleNode1.Parent = primarypart

			createWeld(primarypart, triangleNode1, model.PrimaryPart)

			local triangleNode2: Part = Instance.new("Part")
			triangleNode2.Anchored = false
			triangleNode2.CanCollide = false
			triangleNode2.CanQuery = false
			triangleNode2.CanTouch = false
			triangleNode2.Locked = true
			triangleNode2.Orientation = Vector3.new(0, -90, -90)
			triangleNode2.Position = Vector3.new(primaryPosition.X, modelSize.Y + 0.52, primaryPosition.Z + 1.5)
			triangleNode2.Size = Vector3.new(0.001, 0.001, 0.001)
			triangleNode2.Transparency = 1
			triangleNode2.Parent = primarypart

			createWeld(primarypart, triangleNode2, model.PrimaryPart)

			local flagPole = Instance.new("LineHandleAdornment")
			flagPole.Color3 = Color3.fromRGB(255, 255, 255)
			flagPole.Length = 10
			flagPole.Thickness = 2
			flagPole.Adornee = primarypart
			flagPole.Color3 = BrickColor.new(color).Color
			flagPole.Length = modelSize.Y
			flagPole.Parent = primarypart

			local triangle1 = CreateFlagTriangle()
			triangle1.Adornee = triangleNode1
			triangle1.Color3 = BrickColor.new(color).Color
			triangle1.Parent = primarypart

			local triangle2 = CreateFlagTriangle()
			triangle2.Adornee = triangleNode2
			triangle2.Color3 = BrickColor.new(color).Color
			triangle2.Parent = primarypart

			if primarypart and primarypart:IsA("Part") then
				createWeld(primarypart, primarypart, model.PrimaryPart)				
			end
		end
	end
end

--local function removeVehicleSeatTag(object: VehicleSeat): ()
--	CollectionService:RemoveTag(object, "ControllerSeat")
--end

local function oldifyMain(descendant: Instance): ()
	if descendant:IsA("Terrain") then
		return
	end
	
	if descendant:IsA("Part") and descendant.Shape == Enum.PartType.Cylinder then
		fakeCylinderEffect(descendant)
	end
end

--local function disconnect(descendant: Instance): ()
--	if descendant:IsA("VehicleSeat") then
--		removeVehicleSeatTag(descendant)
--	end
--end

for _: number, v: Instance in pairs(workspace:GetDescendants()) do
	oldifyMain(v)
end

workspace.DescendantAdded:Connect(oldifyMain)
--workspace.DescendantRemoving:Connect(disconnect)

if ReplicatedStorage:WaitForChild("Solo").Value == true then
	Players.PlayerAdded:Connect(function(player: Player) --very nice spaghetti pasta code
		print(player.Name.." is the solo player")
		
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v:GetAttribute("Controller") ~= nil then
				if v:GetAttribute("Controller") ~= "None" then
					for _, part in pairs(v:GetDescendants()) do
						if part:IsA("BasePart") then
							if part.Anchored == false then
								part:SetNetworkOwner(player)
							end
						end
					end
				end
			end
		end
	end)
end