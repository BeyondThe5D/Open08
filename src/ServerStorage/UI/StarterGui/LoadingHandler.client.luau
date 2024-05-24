--[[

	FWM Official, 2023
	Rewrite of Loading Handler - Roblox_Gamer2030

]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService: UserInputService = game:GetService("UserInputService")

local Protocols = ReplicatedStorage:WaitForChild("Protocols")
local CustomFont = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CustomFont"))

local BrickSnapsLoadingUI = script.Parent.LoadingFrame
local currentCamera = workspace.CurrentCamera

local Connections = {}

local objectsLoading = {}
local partsLoaded = {}

local snapsCount: number = 0

local timer = 0

local minLoadInFrame = 1
local maxLoadInFrame = 1500

local validClasses: { [string] : boolean } = {
	Part = true,
	Decal = true
}

local finishedLoading: boolean = false

local function zoomToExtents(camera: Camera, instance: Instance)
	local instanceCFrame: CFrame | false = instance:IsA("Model") and instance:GetPivot() or instance:IsA("BasePart") and instance.CFrame
	local extentsSize: Vector3 | false = instance:IsA("Model") and instance:GetExtentsSize() or instance:IsA("BasePart") and instance.Size

	if instanceCFrame and extentsSize then
		local cameraOffset: number = 500 + extentsSize.Magnitude
		local cameraRotation: CFrame = camera.CFrame - camera.CFrame.Position

		local instancePosition: Vector3 = instanceCFrame.Position
		camera.CFrame = cameraRotation + instancePosition + (-cameraRotation.LookVector * cameraOffset)
		camera.Focus = cameraRotation + instancePosition
	end
end

local function handleObject(obj: Instance): ()
	if validClasses[obj.ClassName] then
		local findObject = table.find(objectsLoading, obj)

		if findObject then
			return
		end

		table.insert(objectsLoading, obj)

		if obj:IsA("BasePart") then
			obj.LocalTransparencyModifier = 1
		end
	end
end

local function addAndDestroy(obj: Instance): ()
	if validClasses[obj.ClassName] then
		local findObject = table.find(objectsLoading, obj)
		local alreadyLoaded = table.find(partsLoaded, obj)

		if findObject and not alreadyLoaded then
			table.remove(objectsLoading, findObject)

			if obj:IsA("Part") then
				table.insert(partsLoaded, obj)

				local getJoints = #obj:GetJoints()
				snapsCount += getJoints

				zoomToExtents(workspace.CurrentCamera, obj)
			end

			if obj:IsA("BasePart") then
				obj.LocalTransparencyModifier = 0
			end

			BrickSnapsLoadingUI.MainLabel.Text = string.format("Bricks: %d    Snaps: %d", #partsLoaded, snapsCount)
		end
	end
end

local function onDestroyed(obj: Instance): ()
	if validClasses[obj.ClassName] then
		local findObject = table.find(objectsLoading, obj)
		local alreadyLoaded = table.find(partsLoaded, obj)

		if findObject then
			table.remove(objectsLoading, findObject)

			if obj:IsA("Part") then
				local getJoints = #obj:GetJoints()
				snapsCount -= getJoints
			end
		elseif alreadyLoaded then
			table.remove(partsLoaded, alreadyLoaded)
		end
	end
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
UserInputService.MouseIconEnabled = false

BrickSnapsLoadingUI.MainLabel.Font = Enum.Font.Cartoon
BrickSnapsLoadingUI.Visible = true

currentCamera.CameraType = Enum.CameraType.Follow

for i: number, v: Instance in pairs(workspace:GetDescendants()) do
	handleObject(v)
end

table.insert(Connections, workspace.DescendantAdded:Connect(handleObject))
table.insert(Connections, workspace.DescendantRemoving:Connect(onDestroyed))

task.wait(2)

while not finishedLoading do
	for i: number = 1, math.random(minLoadInFrame, maxLoadInFrame) do
		if objectsLoading[1] then
			addAndDestroy(objectsLoading[1])
		end
	end

	finishedLoading = #objectsLoading <= 0

	task.wait(0.03)
end

-- useless micro opt but WHATEVER LOL
for i: number, v: RBXScriptConnection in pairs(Connections) do
	v:Disconnect()
end
table.clear(Connections)

task.wait(2)

BrickSnapsLoadingUI.MainLabel.Text = "Requesting character"	

task.wait(1.5)

BrickSnapsLoadingUI.MainLabel.Text = "Waiting for character"	
Protocols.LoadForFirstTime:FireServer()