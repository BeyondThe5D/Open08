local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local MaterialService = game:GetService("MaterialService")
local RunService = game:GetService("RunService")
local MaterialService = game:GetService("MaterialService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local startTime: number = os.clock()

-- Is the game a solo or public server? To make sure we do not interfere with Team Test, an :IsStudio check is required!
if game.PrivateServerId ~= "" and not RunService:IsStudio() then
	ReplicatedStorage.Solo.Value = true
end

--local Shiny = Instance.new("MaterialVariant")
--Shiny.Name = "Shiny"
--Shiny.BaseMaterial = Enum.Material.SmoothPlastic
--Shiny.RoughnessMap = "rbxassetid://11353192201"
--Shiny.Parent = MaterialService

local Sounds = {
	Boing = 12221944,
	Bomb = 12221984,
	Break = 12222005,
	Click = 12222170,
	Clock = 12221976,
	Page = 12222076,
	Ping = 12221990,
	Slingshot = 12222103,
	Snap = 12222140,
	Splat = 12222152,
	Step = 12222183,
	StepOn = 12221996,
	Swoosh = 12222200,
	Victory = 12222253
}

for names, soundids in pairs(Sounds) do
	local Sound = Instance.new("Sound")
	Sound.Name = names
	Sound.SoundId = "rbxassetid://" .. soundids
	Sound.Parent = SoundService
end

local Solo = Instance.new("BoolValue")
Solo.Name = "Solo"
Solo.Parent = ReplicatedStorage

local Protocols = Instance.new("Folder")
Protocols.Name = "Protocols"
Protocols.Parent = ReplicatedStorage

local HintFolder = Instance.new("Folder")
HintFolder.Name = "HintFolder"
HintFolder.Parent = ReplicatedStorage

local Animate = Instance.new("Folder")
Animate.Name = "Animate"
Animate.Parent = StarterPlayer.StarterCharacterScripts

local Reserve = Instance.new("Folder")
Reserve.Name = "Reserve"
Reserve.Parent = ServerStorage

local HopperBins = Instance.new("Folder")
HopperBins.Name = "HopperBins"
HopperBins.Parent = ServerStorage

local Chat = Instance.new("RemoteEvent")
Chat.Name = "Chat"
Chat.Parent = Protocols

local StarterCharacter = Instance.new("Model")
StarterCharacter.Name = "StarterCharacter"
StarterCharacter.Parent = StarterPlayer
local Humanoid = Instance.new("Humanoid")
Humanoid.Parent = StarterCharacter

local function CreateLimbTemplate(dontBlockfiy : boolean)
	local NewLimb = Instance.new("Part")
	NewLimb.Locked = true
	NewLimb.Parent = StarterCharacter

	if not dontBlockfiy then
		local Blockify = Instance.new("SpecialMesh")
		Blockify.MeshType = Enum.MeshType.Brick
		Blockify.Parent = NewLimb
	end

	return NewLimb
end

local Head = CreateLimbTemplate()
Head.Name = "Head"
Head.BrickColor = BrickColor.Yellow()
Head.Size = Vector3.new(2, 1, 1)
Head.TopSurface = Enum.SurfaceType.Smooth
Head.BottomSurface = Enum.SurfaceType.Smooth
local Torso = CreateLimbTemplate()
Torso.Name = "Torso"
Torso.BrickColor = BrickColor.Blue()
Torso.Size = Vector3.new(2, 2, 1)
Torso.Position = Vector3.new(0, -1.5, 0)
Torso.LeftSurface = Enum.SurfaceType.Weld
Torso.RightSurface = Enum.SurfaceType.Weld
local LeftArm = CreateLimbTemplate()
LeftArm.Name = "Left Arm"
LeftArm.BrickColor = BrickColor.Yellow()
LeftArm.Size = Vector3.new(1, 2, 1)
LeftArm.Position = Vector3.new(-1.5, -1.5, 0)
LeftArm.BottomSurface = Enum.SurfaceType.Inlet
local RightArm = CreateLimbTemplate()
RightArm.Name = "Right Arm"
RightArm.BrickColor = BrickColor.Yellow()
RightArm.Size = Vector3.new(1, 2, 1)
RightArm.Position = Vector3.new(1.5, -1.5, 0)
RightArm.BottomSurface = Enum.SurfaceType.Inlet
local LeftLeg = CreateLimbTemplate()
LeftLeg.Name = "Left Leg"
LeftLeg.BrickColor = BrickColor.new(119)
LeftLeg.Size = Vector3.new(1, 2, 1)
LeftLeg.Position = Vector3.new(-0.5, -3.5, 0)
LeftLeg.BottomSurface = Enum.SurfaceType.Smooth
local RightLeg = CreateLimbTemplate()
RightLeg.Name = "Right Leg"
RightLeg.BrickColor = BrickColor.new(119)
RightLeg.Size = Vector3.new(1, 2, 1)
RightLeg.Position = Vector3.new(0.5, -3.5, 0)
RightLeg.BottomSurface = Enum.SurfaceType.Smooth

StarterCharacter.PrimaryPart = Head

local HeadMesh = Instance.new("SpecialMesh")
HeadMesh.MeshType = Enum.MeshType.Head
HeadMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
HeadMesh.Parent = Head
local Face = Instance.new("Decal")
Face.Name = "face"
Face.Texture = "rbxasset://textures/face.png"
Face.Parent = Head
local TShirt = Instance.new("Decal")
TShirt.Name = "roblox"
TShirt.Texture = "rbxassetid://17594040095"
TShirt.Parent = Torso

local function CreateMotor6D()
	local NewMotor6D = Instance.new("Motor6D")
	NewMotor6D.Part0 = Torso
	NewMotor6D.Parent = Torso

	return NewMotor6D
end

local Neck = CreateMotor6D()
Neck.Name = "Neck"
Neck.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(-180), 0)
Neck.C1 = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(-90), math.rad(-180), 0)
Neck.MaxVelocity = 0.15
Neck.Part1 = Head
local LeftShoulder = CreateMotor6D()
LeftShoulder.Name = "Left Shoulder"
LeftShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
LeftShoulder.C1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
LeftShoulder.MaxVelocity = 0.15
LeftShoulder.Part1 = LeftArm
local RightShoulder = CreateMotor6D()
RightShoulder.Name = "Right Shoulder"
RightShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
RightShoulder.C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
RightShoulder.MaxVelocity = 0.15
RightShoulder.Part1 = RightArm
local LeftHip = CreateMotor6D()
LeftHip.Name = "Left Hip"
LeftHip.C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0)
LeftHip.C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(0, math.rad(-90), 0)
LeftHip.MaxVelocity = 0.15
LeftHip.Part1 = LeftLeg
local RightHip = CreateMotor6D()
RightHip.Name = "Right Hip"
RightHip.C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0)
RightHip.C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(0, math.rad(90), 0)
RightHip.MaxVelocity = 0.15
RightHip.Part1 = RightLeg

local TorsoAttach = Instance.new("Attachment")
TorsoAttach.Name = "TorsoAttach"
TorsoAttach.CFrame = CFrame.new() * CFrame.Angles(0, math.rad(90), 0)
TorsoAttach.Axis = Vector3.new(0, 0, -1)
TorsoAttach.Parent = Torso
local AngularTilt = Instance.new("AngularVelocity")
AngularTilt.Name = "AngularTilt"
AngularTilt.Enabled = false
AngularTilt.Attachment0 = TorsoAttach
AngularTilt.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
AngularTilt.Parent = TorsoAttach

-- UI

local Loading = Instance.new("ScreenGui")
Loading.Name = "Loading"
Loading.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
Loading.IgnoreGuiInset = true
Loading.ResetOnSpawn = false
Loading.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Loading:SetAttribute("DontGiveAgain", true)
Loading.Parent = ServerStorage.UI.StarterGui
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
LoadingFrame.BackgroundTransparency = 0.6
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadingFrame.Size = UDim2.new(0.6, 0, 0.18, 0)
LoadingFrame.SizeConstraint = Enum.SizeConstraint.RelativeXX
LoadingFrame.Visible = false
LoadingFrame.Parent = Loading
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(153, 153, 153)
UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
UIStroke.Thickness = 2
UIStroke.Parent = LoadingFrame
local MainLabel = Instance.new("TextLabel")
MainLabel.Name = "MainLabel"
MainLabel.BackgroundTransparency = 1
MainLabel.Size = UDim2.new(1, 0, 1, 0)
MainLabel.Font = Enum.Font.GothamBold
MainLabel.Text = "Connecting to Server..."
MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MainLabel.TextSize = 28
MainLabel.Parent = LoadingFrame
ServerStorage.UI.StarterGui.LoadingHandler.Parent = Loading

local MainResetGui = Instance.new("ScreenGui")
MainResetGui.Name = "MainResetGui"
MainResetGui.DisplayOrder = 2
MainResetGui.IgnoreGuiInset = true
MainResetGui.Parent = ServerStorage.UI.StarterGui
local WinXPCursor = Instance.new("ImageLabel")
WinXPCursor.Name = "WinXPCursor"
WinXPCursor.BackgroundTransparency = 1
WinXPCursor.Size = UDim2.new(0, 17, 0, 25)
WinXPCursor.Visible = false
WinXPCursor.Image = "rbxassetid://13610996027"
WinXPCursor.ResampleMode = Enum.ResamplerMode.Pixelated
WinXPCursor.Parent = MainResetGui
local Cursor = Instance.new("ImageLabel")
Cursor.Name = "Cursor"
Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
Cursor.BackgroundTransparency = 1
Cursor.Size = UDim2.new(0, 128, 0, 128)
Cursor.ZIndex = 10000
Cursor.Image = "rbxassetid://6271122911"
Cursor.Parent = MainResetGui
local RedHealthbarFill = Instance.new("Frame")
RedHealthbarFill.Name = "RedHealthbarFill"
RedHealthbarFill.AnchorPoint = Vector2.new(1, 0)
RedHealthbarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedHealthbarFill.BorderSizePixel = 0
RedHealthbarFill.Position = UDim2.new(1, -60, 0, 200)
RedHealthbarFill.Size = UDim2.new(0.124, 0, 0.124, 0)
RedHealthbarFill.SizeConstraint = Enum.SizeConstraint.RelativeYY
RedHealthbarFill.Parent = MainResetGui
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.AspectRatio = 0.097
UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
UIAspectRatioConstraint.Parent = RedHealthbarFill
local GreenHealthbarFill = Instance.new("Frame")
GreenHealthbarFill.Name = "GreenHealthbarFill"
GreenHealthbarFill.AnchorPoint = Vector2.new(0, 1)
GreenHealthbarFill.BackgroundColor3 = Color3.fromRGB(129, 196, 22)
GreenHealthbarFill.BorderSizePixel = 0
GreenHealthbarFill.Position = UDim2.new(0, 0, 1, 0)
GreenHealthbarFill.Size = UDim2.new(1, 0, 1, 0)
GreenHealthbarFill.ZIndex = 2
GreenHealthbarFill.Parent = RedHealthbarFill
local HealthText = Instance.new("TextLabel")
HealthText.AnchorPoint = Vector2.new(0.5, 0)
HealthText.BackgroundTransparency = 1
HealthText.Position = UDim2.new(0.5, 0, 0.929, 5)
HealthText.Size = UDim2.new(7.46, 0, 0.296, 0)
HealthText.Font = Enum.Font.GothamBold -- meant to be italic
HealthText.Text = "Health"
HealthText.TextColor3 = Color3.fromRGB(0, 0, 255)
HealthText.TextScaled = true
HealthText.Parent = RedHealthbarFill
local Debug = Instance.new("Frame")
Debug.Name = "Debug"
Debug.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
Debug.BackgroundTransparency = 0.6
Debug.BorderSizePixel = 0
Debug.Position = UDim2.new(0, 50, 0, 40)
Debug.Size = UDim2.new(0, 310, 0, 96)
Debug.Visible = false
Debug.Parent = MainResetGui
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 32)
UIPadding.PaddingRight = UDim.new(0, 32)
UIPadding.Parent = Debug
local DebugText = Instance.new("TextLabel")
DebugText.Name = "DebugText"
DebugText.BackgroundTransparency = 1
DebugText.Size = UDim2.new(1, 0, 1, 0)
DebugText.ZIndex = 9
DebugText.Font = Enum.Font.GothamBold
DebugText.Text = "-- FWM Debug --"
DebugText.TextColor3 = Color3.fromRGB(178, 0, 255)
DebugText.TextSize = 16
DebugText.TextXAlignment = Enum.TextXAlignment.Left
DebugText.TextYAlignment = Enum.TextYAlignment.Top
DebugText.Parent = Debug
local Backpack = Instance.new("Frame")
Backpack.Name = "Backpack"
Backpack.AnchorPoint = Vector2.new(0, 1)
Backpack.BackgroundTransparency = 1
Backpack.Position = UDim2.new(0, 0, 1, -20)
Backpack.Size = UDim2.new(0, 0, 0.12, 0)
Backpack.ZIndex = -1
Backpack.Parent = MainResetGui
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.AspectRatio = 8
UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
UIAspectRatioConstraint.Parent = Backpack
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Backpack
Instance.new("UIPadding", MainResetGui) --unused?
ServerStorage.UI.StarterGui.MainResetGuiHandler.Parent = MainResetGui

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MainGui"
MainGui.IgnoreGuiInset = true
MainGui.ResetOnSpawn = false
MainGui.Parent = ServerStorage.UI.StarterGui
Instance.new("UIPadding", MainGui) --unused?
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.BackgroundTransparency = 1
Topbar.Size = UDim2.new(0, 666, 0, 40)
Topbar.ZIndex = 11
Topbar.Parent = MainGui
local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout.CellSize = UDim2.new(0, 100, 0, 20)
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.Parent = Topbar

local function CreateTopbarButton(name : string, greyedOut : boolean)
	local NewTopbarButton = Instance.new("ImageButton")
	NewTopbarButton.Name = name
	NewTopbarButton.AutoButtonColor = false
	NewTopbarButton.BackgroundTransparency = 0.6
	NewTopbarButton.BorderSizePixel = 0
	if not greyedOut then
		NewTopbarButton.HoverImage = "rbxassetid://8090188810"
		NewTopbarButton.ImageTransparency = 0.25
	end
	NewTopbarButton.Parent = Topbar
	local ButtonText = Instance.new("TextLabel")
	ButtonText.Name = "ButtonText"
	ButtonText.BackgroundTransparency = 1
	ButtonText.Position = UDim2.new(0, 20, 0, 0)
	ButtonText.Size = UDim2.new(1, -20, 1, 0)
	ButtonText.ZIndex = 4
	ButtonText.Font = Enum.Font.GothamBold
	ButtonText.Text = name
	ButtonText.TextColor3 = (greyedOut and Color3.fromRGB(170, 170, 170)) or Color3.fromRGB(76, 76, 76)
	ButtonText.TextSize = 14
	ButtonText.TextXAlignment = Enum.TextXAlignment.Left
	ButtonText.Parent = NewTopbarButton
	
	return NewTopbarButton
end

CreateTopbarButton("Tools", true)
CreateTopbarButton("Insert", true)
CreateTopbarButton("Fullscreen")
CreateTopbarButton("Help...")
CreateTopbarButton("Exit")

local ChatBar = Instance.new("Frame")
ChatBar.Name = "ChatBar"
ChatBar.AnchorPoint = Vector2.new(0, 1)
ChatBar.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
ChatBar.BorderSizePixel = 0
ChatBar.Position = UDim2.new(0, 0, 1, 0)
ChatBar.Size = UDim2.new(1, 0, 0, 20)
ChatBar.Parent = MainGui
local TextBox = Instance.new("TextBox")
TextBox.BackgroundTransparency = 1
TextBox.ClearTextOnFocus = false
TextBox.Size = UDim2.new(1, 0, 1, 0)
TextBox.Font = Enum.Font.ArialBold
TextBox.Text = "To chat click here or press the \"/\" key"
TextBox.TextColor3 = Color3.fromRGB(255, 255, 200)
TextBox.TextSize = 12
TextBox.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top
TextBox.Parent = ChatBar
local ChatBarBlock = Instance.new("Frame")
ChatBarBlock.AnchorPoint = Vector2.new(0, 1)
ChatBarBlock.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
ChatBarBlock.BorderSizePixel = 0
ChatBarBlock.Position = UDim2.new(0, 0, 1, 0)
ChatBarBlock.Size = UDim2.new(1, 0, 0, 5)
ChatBarBlock.Parent = ChatBar
local TextPadding = Instance.new("UIPadding")
TextPadding.PaddingLeft = UDim.new(0, 3)
TextPadding.PaddingTop = UDim.new(0, 2)
TextPadding.Parent = TextBox

local ChatWindow = Instance.new("Frame")
ChatWindow.Name = "ChatWindow"
ChatWindow.BackgroundTransparency = 1
ChatWindow.Position = UDim2.new(0, 24, 0, 90)
ChatWindow.Size = UDim2.new(0, 100, 0, 100)
ChatWindow.Parent = MainGui
local UIListLayout2 = Instance.new("UIListLayout")
UIListLayout2.Padding = UDim.new(0, -2)
UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout2.Parent = ChatWindow
local CameraControl = Instance.new("Frame")
CameraControl.Name = "CameraControl"
CameraControl.AnchorPoint = Vector2.new(1, 1)
CameraControl.BackgroundTransparency = 1
CameraControl.Position = UDim2.new(1, -20, 1, -15)
CameraControl.Size = UDim2.new(0, 72, 0, 72)
CameraControl.Parent = MainGui
local CameraButtons = Instance.new("Frame")
CameraButtons.Name = "CameraButtons"
CameraButtons.BackgroundTransparency = 1
CameraButtons.Size = UDim2.new(1, 0, 1, 0)
CameraButtons.Parent = CameraControl
local UIGridLayout2 = Instance.new("UIGridLayout")
UIGridLayout2.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout2.CellSize = UDim2.new(0, 36, 0, 36)
UIGridLayout2.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout2.Parent = CameraButtons
local UIScale = Instance.new("UIScale")
UIScale.Scale = 0.95
UIScale.Parent = CameraButtons
local CameraTiltDown = Instance.new("ImageButton")
CameraTiltDown.Name = "CameraTiltDown"
CameraTiltDown.AnchorPoint = Vector2.new(1, 1)
CameraTiltDown.BackgroundTransparency = 1
CameraTiltDown.LayoutOrder = 2
CameraTiltDown.Position = UDim2.new(1, 0, 1, 0)
CameraTiltDown.Size = UDim2.new(0, 32, 0, 32)
CameraTiltDown.HoverImage = "rbxassetid://6680556292"
CameraTiltDown.Image = "rbxassetid://6270912147"
CameraTiltDown.PressedImage = "http://www.roblox.com/asset/?id=6680556069"
CameraTiltDown.Parent = CameraButtons
local CameraTiltUp = Instance.new("ImageButton")
CameraTiltUp.Name = "CameraTiltUp"
CameraTiltUp.AnchorPoint = Vector2.new(1, 1)
CameraTiltUp.BackgroundTransparency = 1
CameraTiltUp.LayoutOrder = 0
CameraTiltUp.Position = UDim2.new(1, 0, 1, 0)
CameraTiltUp.Size = UDim2.new(0, 32, 0, 32)
CameraTiltUp.HoverImage = "rbxassetid://6680556883"
CameraTiltUp.Image = "rbxassetid://6270911470"
CameraTiltUp.PressedImage = "http://www.roblox.com/asset/?id=6680556654"
CameraTiltUp.Parent = CameraButtons
local CameraZoomIn = Instance.new("ImageButton")
CameraZoomIn.Name = "CameraZoomIn"
CameraZoomIn.AnchorPoint = Vector2.new(1, 1)
CameraZoomIn.BackgroundTransparency = 1
CameraZoomIn.LayoutOrder = 1
CameraZoomIn.Position = UDim2.new(1, 0, 1, 0)
CameraZoomIn.Size = UDim2.new(0, 32, 0, 32)
CameraZoomIn.HoverImage = "rbxassetid://6680557474"
CameraZoomIn.Image = "rbxassetid://6270912438"
CameraZoomIn.PressedImage = "http://www.roblox.com/asset/?id=6680557150"
CameraZoomIn.Parent = CameraButtons
local CameraZoomOut = Instance.new("ImageButton")
CameraZoomOut.Name = "CameraZoomOut"
CameraZoomOut.AnchorPoint = Vector2.new(1, 1)
CameraZoomOut.BackgroundTransparency = 1
CameraZoomOut.LayoutOrder = 3
CameraZoomOut.Position = UDim2.new(1, 0, 1, 0)
CameraZoomOut.Size = UDim2.new(0, 32, 0, 32)
CameraZoomOut.HoverImage = "rbxassetid://6680557849"
CameraZoomOut.Image = "rbxassetid://6270912749"
CameraZoomOut.PressedImage = "http://www.roblox.com/asset/?id=6680557657"
CameraZoomOut.Parent = CameraButtons
local ReportButton = Instance.new("ImageButton")
ReportButton.Name = "ReportButton"
ReportButton.AnchorPoint = Vector2.new(0, 1)
ReportButton.BackgroundTransparency = 1
ReportButton.Position = UDim2.new(1, -75, 1, -72)
ReportButton.Size = UDim2.new(1, 0, 1, 0)
ReportButton.Visible = false
ReportButton.HoverImage = "rbxassetid://12483991631"
ReportButton.Image = "rbxassetid://12483992432"
ReportButton.PressedImage = "rbxassetid://12483992314"
ReportButton.Parent = CameraControl
local ZoomedOut = Instance.new("Frame")
ZoomedOut.Name = "ZoomedOut"
ZoomedOut.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ZoomedOut.BackgroundTransparency = 0.6
ZoomedOut.BorderSizePixel = 0
ZoomedOut.Position = UDim2.new(0.48, 0, 0.48, 0)
ZoomedOut.Size = UDim2.new(0, 32, 0, 32)
ZoomedOut.Visible = false
ZoomedOut.Parent = CameraControl
local ZoomedIn = Instance.new("Frame")
ZoomedIn.Name = "ZoomedIn"
ZoomedIn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ZoomedIn.BackgroundTransparency = 0.6
ZoomedIn.BorderSizePixel = 0
ZoomedIn.Position = UDim2.new(0.48, 0, 0, 0)
ZoomedIn.Size = UDim2.new(0, 32, 0, 32)
ZoomedIn.Visible = false
ZoomedIn.Parent = CameraControl

local SuperSafeChatBubble = Instance.new("ImageButton")
SuperSafeChatBubble.Name = "SuperSafeChatBubble"
SuperSafeChatBubble.AnchorPoint = Vector2.new(0, 1)
SuperSafeChatBubble.BackgroundTransparency = 1
SuperSafeChatBubble.Position = UDim2.new(0.025, 0, 0.75, 0)
SuperSafeChatBubble.Size = UDim2.new(0, 33, 0, 31)
SuperSafeChatBubble.Visible = false
SuperSafeChatBubble.HoverImage = "rbxassetid://12483705674"
SuperSafeChatBubble.Image = "rbxassetid://12483706070"
SuperSafeChatBubble.Parent = MainGui
local List = Instance.new("Frame")
List.Name = "List"
List.BackgroundTransparency = 1
List.Position = UDim2.new(1, 5, 0, 0)
List.Size = UDim2.new(0, 100, 1, 0)
List.Visible = false
List.Parent = SuperSafeChatBubble
local UIListLayout3 = Instance.new("UIListLayout")
UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout3.Parent = List

local ControllerFlags = Instance.new("Frame")
ControllerFlags.Name = "ControllerFlags"
ControllerFlags.BackgroundTransparency = 1
ControllerFlags.Size = UDim2.new(1, 0, 1, 0)
ControllerFlags.ZIndex = 9
ControllerFlags.Parent = MainGui
local UIListLayout4 = Instance.new("UIListLayout")
UIListLayout4.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout4.Parent = ControllerFlags
local UIPadding2 = Instance.new("UIPadding")
UIPadding2.PaddingTop = UDim.new(0, 20)
UIPadding2.Parent = ControllerFlags
local KeyboardLeft = Instance.new("Frame")
KeyboardLeft.Name = "KeyboardLeft"
KeyboardLeft.BackgroundTransparency = 1
KeyboardLeft.Size = UDim2.new(0, 96, 0, 69)
KeyboardLeft.Visible = false
KeyboardLeft.ZIndex = 1000
KeyboardLeft.Parent = ControllerFlags
local A = Instance.new("ImageLabel")
A.Name = "A"
A.BackgroundTransparency = 1
A.Position = UDim2.new(0, 0, 0, 37)
A.Size = UDim2.new(0, 32, 0, 32)
A.ZIndex = 1000
A.Image = "rbxassetid://7705615187"
A.Parent = KeyboardLeft
local D = Instance.new("ImageLabel")
D.Name = "D"
D.BackgroundTransparency = 1
D.Position = UDim2.new(0, 64, 0, 37)
D.Size = UDim2.new(0, 32, 0, 32)
D.ZIndex = 1000
D.Image = "rbxassetid://7705615180"
D.Parent = KeyboardLeft
local Flag = Instance.new("ImageLabel")
Flag.Name = "Flag"
Flag.BackgroundTransparency = 1
Flag.Position = UDim2.new(0, 0, 0, 5)
Flag.Size = UDim2.new(0, 32, 0, 32)
Flag.ZIndex = 1000
Flag.Image = "rbxassetid://7705606368"
Flag.Parent = KeyboardLeft
local S = Instance.new("ImageLabel")
S.Name = "S"
S.BackgroundTransparency = 1
S.Position = UDim2.new(0, 32, 0, 37)
S.Size = UDim2.new(0, 32, 0, 32)
S.ZIndex = 1000
S.Image = "rbxassetid://7705615181"
S.Parent = KeyboardLeft
local W = Instance.new("ImageLabel")
W.Name = "W"
W.BackgroundTransparency = 1
W.Position = UDim2.new(0, 32, 0, 5)
W.Size = UDim2.new(0, 32, 0, 32)
W.ZIndex = 1000
W.Image = "rbxassetid://7705615191"
W.Parent = KeyboardLeft
local KeyboardRight = Instance.new("Frame")
KeyboardRight.Name = "KeyboardRight"
KeyboardRight.BackgroundTransparency = 1
KeyboardRight.Size = UDim2.new(0, 96, 0, 69)
KeyboardRight.Visible = false
KeyboardRight.ZIndex = 1000
KeyboardRight.Parent = ControllerFlags
local Flag = Instance.new("ImageLabel")
Flag.Name = "Flag"
Flag.BackgroundTransparency = 1
Flag.Position = UDim2.new(0, 0, 0, 0)
Flag.Size = UDim2.new(0, 32, 0, 32)
Flag.ZIndex = 1000
Flag.Image = "rbxassetid://7705606368"
Flag.Parent = KeyboardRight
local H = Instance.new("ImageLabel")
H.Name = "H"
H.BackgroundTransparency = 1
H.Position = UDim2.new(0, 0, 0, 32)
H.Size = UDim2.new(0, 32, 0, 32)
H.ZIndex = 1000
H.Image = "rbxassetid://6514388413"
H.Parent = KeyboardRight
local J = Instance.new("ImageLabel")
J.Name = "J"
J.BackgroundTransparency = 1
J.Position = UDim2.new(0, 32, 0, 32)
J.Size = UDim2.new(0, 32, 0, 32)
J.ZIndex = 1000
J.Image = "rbxassetid://6514241713"
J.Parent = KeyboardRight
local K = Instance.new("ImageLabel")
K.Name = "K"
K.BackgroundTransparency = 1
K.Position = UDim2.new(0, 64, 0, 32)
K.Size = UDim2.new(0, 32, 0, 32)
K.ZIndex = 1000
K.Image = "rbxassetid://6514247137"
K.Parent = KeyboardRight
local U = Instance.new("ImageLabel")
U.Name = "U"
U.BackgroundTransparency = 1
U.Position = UDim2.new(0, 32, 0, 0)
U.Size = UDim2.new(0, 32, 0, 32)
U.ZIndex = 1000
U.Image = "rbxassetid://6514249438"
U.Parent = KeyboardRight

local Leaderboard = Instance.new("Frame")
Leaderboard.Name = "Leaderboard"
Leaderboard.AnchorPoint = Vector2.new(1, 0)
Leaderboard.BackgroundTransparency = 1
Leaderboard.Position = UDim2.new(1, -10, 0, 10)
Leaderboard.Size = UDim2.new(0.162, 0, 0.018, 0)
Leaderboard.SizeConstraint = Enum.SizeConstraint.RelativeXX
Leaderboard.ZIndex = 8
Leaderboard.Parent = MainGui
local UIListLayout5 = Instance.new("UIListLayout")
UIListLayout5.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout5.Parent = Leaderboard
local TeamSplit_VeryBottom = Instance.new("Frame")
TeamSplit_VeryBottom.Name = "TeamSplit_VeryBottom"
TeamSplit_VeryBottom.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
TeamSplit_VeryBottom.BackgroundTransparency = 0.6
TeamSplit_VeryBottom.BorderSizePixel = 0
TeamSplit_VeryBottom.LayoutOrder = 999999999
TeamSplit_VeryBottom.Position = UDim2.new(0, 0, 1, 0)
TeamSplit_VeryBottom.Size = UDim2.new(1, 0, 2.25, 0)
TeamSplit_VeryBottom.Visible = false
TeamSplit_VeryBottom.ZIndex = 10
TeamSplit_VeryBottom.Parent = Leaderboard
local TopSplit = Instance.new("Frame")
TopSplit.Name = "TopSplit"
TopSplit.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
TopSplit.BackgroundTransparency = 0.6
TopSplit.BorderSizePixel = 0
TopSplit.LayoutOrder = -1
TopSplit.Position = UDim2.new(0, 0, 1, 0)
TopSplit.Size = UDim2.new(1, 0, 0.502, 0)
TopSplit.ZIndex = 8
TopSplit.Parent = Leaderboard
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
TopBar.BackgroundTransparency = 0.6
TopBar.BorderSizePixel = 0
TopBar.LayoutOrder = -2
TopBar.Position = UDim2.new(-0.15, 0, 0.633, 0)
TopBar.Size = UDim2.new(1, 0, 1, 0)
TopBar.ZIndex = 8
TopBar.Parent = Leaderboard
local Player = Instance.new("TextLabel")
Player.Name = "Player"
Player.BackgroundTransparency = 1
Player.Size = UDim2.new(1, 0, 1, 0)
Player.ZIndex = 9
Player.Font = Enum.Font.GothamBold
Player.Text = "Player List"
Player.TextColor3 = Color3.fromRGB(242, 243, 243)
Player.TextScaled = true
Player.TextXAlignment = Enum.TextXAlignment.Left
Player.TextYAlignment = Enum.TextYAlignment.Top
Player.Parent = TopBar
local Leaderstats = Instance.new("Frame")
Leaderstats.Name = "Leaderstats"
Leaderstats.BackgroundTransparency = 1
Leaderstats.Position = UDim2.new(1, 0, 0, 0)
Leaderstats.Size = UDim2.new(0.5, 0, 1, 0)
Leaderstats.Parent = TopBar
local UIGridLayout3 = Instance.new("UIGridLayout")
UIGridLayout3.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout3.CellSize = UDim2.new(1, 0, 1, 0)
UIGridLayout3.FillDirection = Enum.FillDirection.Vertical
UIGridLayout3.FillDirectionMaxCells = 9999
UIGridLayout3.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout3.Parent = Leaderstats
ServerStorage.UI.StarterGui.MainGuiHandler.Parent = MainGui
ServerStorage.UI.StarterGui.MainGuiOffset.Parent = MainGui

-- Replace tools with HopperBin based on Command type:
for _: number, tool: Instance in ipairs(StarterPack:GetChildren()) do
	local hopperBins = ServerStorage.HopperBins
	local hasAttribute = tool:GetAttribute("Command")

	if not hasAttribute then
		print(tool.Name.." does not have a Command attribute assigned! (Ignore if the object is a Tool)")

		continue
	end

	local newHopperBin: Instance? = hopperBins:FindFirstChild(tool:GetAttribute("Command"), false)

	-- If the Command is ScriptHopper, then don't replace anything.
	if tool:GetAttribute("Command") ~= "ScriptHopper" and newHopperBin then
		newHopperBin:Clone().Parent = tool.Parent

		tool:Destroy()
	else
		tool.Parent = ServerStorage.Reserve
	end
end

-- A bit stanky way to fix sorting for ScriptHopper tools.
for _: number, reservedTool: Instance in ipairs(ServerStorage.Reserve:GetChildren()) do
	reservedTool.Parent = StarterPack
end

local endTime: number = os.clock()
local timeElapsed: number = math.floor((endTime - startTime) * 1000)

print("[FRAMEWORK]: Loaded in " .. timeElapsed .. "ms")
