--[[
	FWM Official, 2022
	
	Main Gui that will reset upon respawn - Roblox_Gamer2030
]]
local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TextureGroups = require(ReplicatedStorage:WaitForChild("Modules", nil):WaitForChild("TextureGroups", nil))
local StockSound = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("StockSound"))
local MouseIcon = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MouseIcon"))
local Protocols = ReplicatedStorage:WaitForChild("Protocols")

local MainGui = script.Parent
--local Holder = MainGui:WaitForChild("Holder")
local GameSettings = UserSettings().GameSettings
local LocalPlayer = Players.LocalPlayer
local LocalPlayerGui: PlayerGui = LocalPlayer.PlayerGui
local Mouse = LocalPlayer:GetMouse()
local Solo = ReplicatedStorage:WaitForChild("Solo")
local canGreenDisc: boolean = false
local isMobile = (UserInputService.TouchEnabled and (not UserInputService.MouseEnabled))
--local Settings = LocalPlayer:WaitForChild("PlayerDataFolder"):WaitForChild("UserDataFolder"):WaitForChild("SettingsFolder")

local Character: Model? = LocalPlayer.Character
local Humanoid

local globalGameProcessed: boolean = false

local function CreateGreenDisc()
	local GreenDisc = Instance.new("CylinderHandleAdornment")
	GreenDisc.Color3 = Color3.fromRGB(0, 255, 0)
	GreenDisc.CFrame = CFrame.new() * CFrame.Angles(math.rad(-90), 0, 0)
	GreenDisc.Height = 0.2
	GreenDisc.Visible = false
	
	return GreenDisc
end

local MouseConnectedDisc = CreateGreenDisc()
Mouse.TargetFilter = MouseConnectedDisc
MouseConnectedDisc.Adornee = workspace.Terrain
MouseConnectedDisc.Parent = workspace.CurrentCamera

--local ToolCount = 0
local Tools = {}

local GamepadSelection = 1
local currentDiscMoveTo = nil

local KeyCodes = {

	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
	[Enum.KeyCode.Zero] = 10

}

local YellowHover = Color3.new(1, 1, 0)
local GreenHover = Color3.new(0.14902, 1, 0)
local BlueHover = Color3.new(0, 0, 1)
local White = Color3.new(1, 1, 1)
local DefaultColor = Color3.new(0.701961, 0.701961, 0.701961)

local function findTexture(baseTexture: string, state: string): string
	for i, v in ipairs(TextureGroups) do
		if string.lower(v.base) == string.lower(baseTexture) then
			return v[state]
		end
	end
	
	return baseTexture
end

local function Healthbar(): ()
	MainGui:WaitForChild("RedHealthbarFill"):WaitForChild("GreenHealthbarFill").Size = UDim2.new(1, 0, LocalPlayer.Character.Humanoid.Health/LocalPlayer.Character.Humanoid.MaxHealth, 0)
end

local function DisableOtherBorders(): ()
	for _, v in pairs(script.Parent.Backpack:GetChildren()) do
		if v.ClassName == "TextButton" and tonumber(v.Name) then
			v.Border.Visible = false
		end
	end
end

local function MakeBorderVisible(frame): ()
	--if Settings.TimePeriod.Value ~= "2006M" then
		frame.Border.Visible = true
		frame.Border.ClipsDescendants = true
		frame.Border.ClipsDescendants = false
	--end
end

local function ToolEquipEvent(tool, frame)
	if tool.Parent == LocalPlayer.Character then
		LocalPlayer.Character.Humanoid:UnequipTools()
		DisableOtherBorders()
	else
		LocalPlayer.Character.Humanoid:EquipTool(tool)
		
		if tool:GetAttribute("Command") and tool:GetAttribute("Command") ~= "ScriptHopper" then
			StockSound:PlaySoundLocal("Ping")
		end
		
		DisableOtherBorders()
		MakeBorderVisible(frame)
	end
end

local function RegisterTool(toolobject)
	if not table.find(Tools, toolobject) then
		table.insert(Tools, toolobject)
		--ToolCount = ToolCount + 1

		local newCell = Instance.new("TextButton")
		newCell.Name = "Backpack"
		newCell.AutoButtonColor = false
		newCell.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
		newCell.BackgroundTransparency = 0.6
		newCell.BorderSizePixel = 0
		newCell.Position = UDim2.new(0, 100, 0.997, 0)
		newCell.Size = UDim2.new(1, 0, 1, 0)
		newCell.SizeConstraint = Enum.SizeConstraint.RelativeYY
		newCell.Text = ""
		--newCell.Visible = false -- ## SHIT NIGGER BALL SACK
		local Tool = Instance.new("ObjectValue")
		Tool.Name = "Tool"
		Tool.Value = toolobject
		Tool.Parent = newCell
		
		local Border = Instance.new("Frame")
		Border.Name = "Border"
		Border.BackgroundTransparency = 1
		Border.BorderSizePixel = 0
		Border.Size = UDim2.new(1, 0, 1, 0)
		Border.Visible = false
		Border.ZIndex = 3
		Border.Parent = newCell
		
		local Line1 = Instance.new("Frame")
		Line1.AnchorPoint = Vector2.new(0.5, 0.5)
		Line1.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		Line1.BorderSizePixel = 0
		Line1.Position = UDim2.new(0.5, 0, 0, 0)
		Line1.Size = UDim2.new(1, 3, 0, 3)
		Line1.ZIndex = 3
		Line1.Parent = Border
		local Line2 = Instance.new("Frame")
		Line2.AnchorPoint = Vector2.new(0.5, 0)
		Line2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		Line2.BorderSizePixel = 0
		Line2.Position = UDim2.new(1, 0, 0, 0)
		Line2.Size = UDim2.new(0, 3, 1, 0)
		Line2.ZIndex = 3
		Line2.Parent = Border
		local Line3 = Instance.new("Frame")
		Line3.AnchorPoint = Vector2.new(0.5, 0.5)
		Line3.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		Line3.BorderSizePixel = 0
		Line3.Position = UDim2.new(0.5, 0, 1, -1)
		Line3.Size = UDim2.new(1, 3, 0, 1)
		Line3.ZIndex = 3
		Line3.Parent = Border
		local Line4 = Instance.new("Frame")
		Line4.AnchorPoint = Vector2.new(0.5, 0)
		Line4.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		Line4.BorderSizePixel = 0
		Line4.Position = UDim2.new(0, 0, 0, 0)
		Line4.Size = UDim2.new(0, 3, 1, 0)
		Line4.ZIndex = 3
		Line4.Parent = Border
		
		local Fillin = Instance.new("Frame")
		Fillin.Name = "Fillin"
		Fillin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Fillin.BorderSizePixel = 0
		Fillin.Size = UDim2.new(1, 0, 1, 0)
		Fillin.Visible = false
		Fillin.ZIndex = 4
		Fillin.Parent = newCell
		
		local HoverThing = Instance.new("Frame")
		HoverThing.Name = "HoverThing"
		HoverThing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		HoverThing.BorderSizePixel = 0
		HoverThing.Position = UDim2.new(0.11, 0, 0.125, 0)
		HoverThing.Size = UDim2.new(0.75, 0, 0.75, 0)
		HoverThing.Visible = false
		HoverThing.ZIndex = 4
		HoverThing.Parent = newCell
		
		local ToolImage = Instance.new("ImageLabel")
		ToolImage.Name = "ToolImage"
		ToolImage.BackgroundTransparency = 1
		ToolImage.Position = UDim2.new(0.122, 0, 0.125, 0)
		ToolImage.Size = UDim2.new(0.75, 0, 0.75, 0)
		ToolImage.Visible = false
		ToolImage.ZIndex = 5
		ToolImage.Parent = newCell
		
		local ToolName = Instance.new("TextLabel")
		ToolName.Name = "ToolName"
		ToolName.BackgroundTransparency = 1
		ToolName.Position = UDim2.new(0.206, 0, 0, 0)
		ToolName.Size = UDim2.new(0.794, 0, 1, 0)
		ToolName.Visible = false
		ToolName.ZIndex = 999
		ToolName.Font = Enum.Font.GothamBold
		ToolName.Text = "TOOLNAME"
		ToolName.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToolName.TextSize = 18
		ToolName.TextStrokeColor3 = Color3.fromRGB(128, 128, 128)
		ToolName.TextStrokeTransparency = 0.5
		ToolName.Parent = newCell
		
		local ToolNumber = Instance.new("TextLabel")
		ToolNumber.Name = "ToolNumber"
		ToolNumber.BackgroundColor3 = Color3.fromRGB(199, 199, 199)
		ToolNumber.BorderSizePixel = 0
		ToolNumber.Position = UDim2.new(0.007, 0, 0.809, 0)
		ToolNumber.Size = UDim2.new(0.175, 0, 0.183, 0)
		ToolNumber.ZIndex = 3
		ToolNumber.Font = Enum.Font.GothamBold
		ToolNumber.Text = "1"
		ToolNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToolNumber.TextScaled = true
		ToolNumber.Parent = newCell
		
		newCell.Parent = script.Parent.Backpack
		newCell.Name = #Tools
		newCell.LayoutOrder = newCell.Name

		if toolobject.TextureId ~= "" then
			newCell.ToolName.Text = toolobject.Name
			newCell.ToolImage.Image = toolobject.TextureId
			newCell.ToolImage.Visible = true
		else
			newCell.ToolName.Text = toolobject.Name
			newCell.ToolImage.Image = toolobject.TextureId
			newCell.ToolName.Visible = true
		end
		
		newCell.ToolNumber.Text = newCell.Name
		
		local conns = {}		
		
		conns = {
			newCell:GetPropertyChangedSignal("Name"):Connect(function(): ()
				newCell.ToolNumber.Text = newCell.Name
			end),

			toolobject:GetPropertyChangedSignal("TextureId"):Connect(function(): ()
				if toolobject.TextureId ~= "" then
					newCell.ToolName.Text = toolobject.Name
					newCell.ToolImage.Image = toolobject.TextureId
					newCell.ToolImage.Visible = true
					newCell.ToolName.Visible = false
				else
					newCell.ToolName.Text = toolobject.Name
					newCell.ToolImage.Image = toolobject.TextureId
					newCell.ToolName.Visible = true
					newCell.ToolImage.Visible = false
				end
			end),

			toolobject:GetPropertyChangedSignal("Name"):Connect(function(): ()
				newCell.ToolName.Text = toolobject.Name
			end),
			
			newCell.InputBegan:Connect(function(input: InputObject): ()
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if toolobject.TextureId ~= "" then
						newCell.HoverThing.BackgroundColor3 = YellowHover
						newCell.HoverThing.Visible = true
						newCell.ToolImage.Image = findTexture(toolobject.TextureId, "over")
					else
						newCell.FillIn.BackgroundColor3 = DefaultColor
						newCell.FillIn.Visible = true
					end
				end
			end),

			newCell.MouseButton1Down:Connect(function(x: number, y: number): ()
				if toolobject.TextureId ~= "" then
					newCell.HoverThing.BackgroundColor3 = BlueHover
					newCell.ToolImage.Image = findTexture(toolobject.TextureId, "down")
				else
					newCell.FillIn.BackgroundColor3 = YellowHover
				end
			end),

			newCell.InputEnded:Connect(function(input: InputObject): ()
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if toolobject.TextureId ~= "" then
						newCell.HoverThing.BackgroundColor3 = DefaultColor
						newCell.HoverThing.Visible = false
						newCell.ToolImage.Image = findTexture(toolobject.TextureId, "base")
					else
						newCell.FillIn.BackgroundColor3 = DefaultColor
						newCell.FillIn.Visible = false
					end
				end
			end),

			newCell.MouseButton1Click:Connect(function(): ()
				if toolobject.TextureId ~= "" then
					newCell.HoverThing.BackgroundColor3 = YellowHover
					newCell.ToolImage.Image = findTexture(toolobject.TextureId, "over")
					ToolEquipEvent(newCell.Tool.Value, newCell)
				else
					newCell.FillIn.BackgroundColor3 = DefaultColor
					ToolEquipEvent(newCell.Tool.Value, newCell)
				end
			end),
			
			newCell.AncestryChanged:Connect(function()
				if not newCell.Parent then
					for _, connections in pairs(conns) do
						connections:Disconnect()
					end
				end
			end),
		}

		newCell.Visible = true

		if toolobject.Parent == LocalPlayer.Character then
			DisableOtherBorders()
			MakeBorderVisible(newCell)
		end
	end
end

local function ResortInventory()
	for _, v in pairs(script.Parent.Backpack:GetChildren()) do
		if v:IsA("TextButton") and tonumber(v.Name) then
			local GetTool = v:FindFirstChild("Tool")
			
			if GetTool then
				local FindInTable = table.find(Tools, GetTool.Value)
				
				if FindInTable then
					v.Name = FindInTable
					v.LayoutOrder = v.Name
				end
			end
		end
	end
end

local function UnregisterTool(toolobject)
	local FindTool =  table.find(Tools, toolobject)
	
	if FindTool then
		local FindInBackpack = script.Parent.Backpack:FindFirstChild(FindTool)
		
		if FindInBackpack then
			local GrabbedTool = FindInBackpack:FindFirstChild("Tool")

			if GrabbedTool then
				local IsTool = Tools[FindTool]

				if GrabbedTool.Value == IsTool then -- :rice_scene:'s the tool, then resorts backpack
					FindInBackpack:Destroy()
					table.remove(Tools, FindTool)
					
					ResortInventory()
				end
			end
		end
	end
end

local function ToolChildAdded(child)
	if child:IsA("Tool") then
		local Find = table.find(Tools, child)
		
		if not Find then
			RegisterTool(child)
		end
	end
end

local function ToolChildRemoved(child)
	if child:IsA("Tool") then
		if child.Parent ~= LocalPlayer.Character and child.Parent ~= LocalPlayer.Backpack then
			UnregisterTool(child)
		end
	end
end

local function FrameEquipEvent(num)
	local Find = script.Parent.Backpack:FindFirstChild(tostring(num))
	
	if Find then
		ToolEquipEvent(Find.Tool.Value, Find)
	end
end

local function UserInputEquipItem(key, process)
	if not process then
		local GetKey = KeyCodes[key.KeyCode]
		
		if GetKey then
			FrameEquipEvent(GetKey)
		end
		
		if key.KeyCode == Enum.KeyCode.Backspace then
			DisableOtherBorders()
		end
	end
end 

local function updateMouseIcon(): ()
	local HasTool = Character and Character:FindFirstChildOfClass("Tool") or false
	local GrabbedGuis = LocalPlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
		
	if not MouseConnectedDisc.Visible then
		if GrabbedGuis and not HasTool then
			MouseIcon.Icon("rbxasset://textures\\ArrowFarCursor.png")

			for _, Objects in pairs(GrabbedGuis) do
				if Objects:IsA("GuiButton") then
					MouseIcon.Icon("rbxasset://textures\\ArrowCursor.png")

					break
				end
			end	
		end
	else
		MouseIcon.Icon("rbxasset://textures\\ArrowCursor.png")
	end
end

local Icons = {
	default = {
		Image = "rbxassetid://13610996027";
		ImageColor3 = Color3.new(1, 1, 1);
		Size = UDim2.new(0, 17, 0, 25);
		Priority = 0;
	};

	button = {
		Image = "rbxassetid://13610995901";
		ImageColor3 = Color3.new(1, 1, 1);
		Size = UDim2.new(0, 22, 0, 26);
		Priority = 1;
	};
	
	beam = {
		Image = "rbxassetid://13611975254";
		ImageColor3 = Color3.new(0, 0, 0);
		Size = UDim2.new(0, 7, 0, 16);
		Priority = 2;
	}
};

local mouseStates = {
	-- KEY IF SOMEONE MAKES A GUI W/ THESE NAMES
	-- THEY WILL DEF GO T F???
	
	["ChatBar"] = Icons.beam;
	["ToolboxItem"] = Icons.button;
	["ToolboxWindow"] = Icons.default;
};

local currentMouseFlag;
local function CursorUpdate(input, gameProcessed)
	globalGameProcessed = gameProcessed
	MainGui.Cursor.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y + 36)
	MainGui.WinXPCursor.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y + 36)
	
	local GetGuiObjects = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
	
	if GetGuiObjects then
		local flag;
		for _, v in GetGuiObjects do
			local state = mouseStates[v.Name];
			if(not state)then
				continue;
			elseif(state and not flag)then
				flag = state;
			elseif(state.Priority>flag.Priority)then
				flag = state;
			end
		end

		if(flag and flag~=currentMouseFlag)then			
			currentMouseFlag = flag;
			MainGui.Cursor.Visible = false;
			MainGui.WinXPCursor.Visible = true;
			
			local xpCursor = MainGui.WinXPCursor;
			for name, value in flag do
				if(name == "Priority")then
					continue;
				end
				
				xpCursor[name] = value;
			end
		elseif(not flag and currentMouseFlag)then
			currentMouseFlag = nil;
			MainGui.Cursor.Visible = true;
			MainGui.WinXPCursor.Visible = false;
		end
	end
	
	-- thingy to not have this run twice
	if (not canGreenDisc) then
		updateMouseIcon()
	end
	
	--if CurrentTimePeriod >= 6 then	
	--	local GetTool = Character:FindFirstChildOfClass("Tool")
	--	local GrabbedGuis = LocalPlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
		
	--	if GrabbedGuis and not GetTool then		
	--		if not MouseConnectedDisc.Visible then
	--			MouseIcon.Icon("rbxasset://textures\\ArrowFarCursor.png")
				
	--			for _, Objects in pairs(GrabbedGuis) do
	--				if Objects:IsA("GuiButton") then
	--					MouseIcon.Icon("rbxasset://textures\\ArrowCursor.png")

	--					break
	--				end
	--			end	
	--		else
	--			MouseIcon.Icon("rbxasset://textures\\ArrowCursor.png")
	--		end
	--	end
	--end
end

--Hookup:

---- Debug stuff

function roundNumber(num, numPlaces)
	return math.floor(num*(10^numPlaces))/(10^numPlaces)
end

--function DebugUpdate()
--	if Character:FindFirstChild("Torso") then
--		--MainGui.Debug.DebugText.Text = "-- FWM Debug --\nSTATE: "..Character.Humanoid:GetState().Name.."\nMAG: "..roundNumber(Character.Torso.AssemblyLinearVelocity.Magnitude, 1).."\nTIME: "..roundNumber(workspace.DistributedGameTime, 1).."\nOBJ: "..#workspace:GetDescendants().."\nVER: "..game.PlaceVersion
--	end
--end

local function DebugToggle(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.F2 then
			MainGui.Debug.Visible = not MainGui.Debug.Visible
		end
	end
end

local function checkIfValid(checkIfdisc: boolean): boolean
	local currentCamera = workspace.CurrentCamera
	local cameraCFrame = currentCamera.CFrame
	
	if Character then
		local hasTool = (not Character:FindFirstChildOfClass("Tool"))
		local hasTorso = Character:FindFirstChild("Torso")
		local notFullyTransparent = false
		local isNotWalking = Humanoid and (Humanoid.MoveDirection == Vector3.zero)
		local isAlive = Humanoid and (Humanoid.Health > 0)
		local discVisible = true

		if checkIfdisc then
			discVisible = MouseConnectedDisc.Visible
		end

		if hasTorso then
			local transparencyModifier = hasTorso.LocalTransparencyModifier

			notFullyTransparent = (transparencyModifier < 1)
		end	

		return (hasTool and notFullyTransparent and isNotWalking and discVisible and isAlive)
	else
		return false
	end
end

local function onMoveToFinished(): ()
	if Character then
		local moveValueInChar = Character:FindFirstChild("isDiscWalking")
		if not moveValueInChar then
			return
		end
		
		if not currentDiscMoveTo then
			return
		end
		
		moveValueInChar.Value = false
		Protocols.DiscWalking:FireServer(false)
		
		currentDiscMoveTo:Destroy()
		currentDiscMoveTo = nil
	end
end

local function greenDiskMain(dt: number): ()
	local mouseHit = Mouse.Hit.Position
	local distanceFromChar = LocalPlayer:DistanceFromCharacter(mouseHit)
	local canDo = checkIfValid(false)
	
	if canDo and distanceFromChar < 40 and not globalGameProcessed then
		MouseConnectedDisc.Visible = true
		MouseConnectedDisc.CFrame = CFrame.new(mouseHit) * CFrame.Angles(math.pi / 2, 0, 0)
	else
		MouseConnectedDisc.Visible = false
	end
	
	updateMouseIcon()
end

local function clickToMoveMainInput(input, gameProcessed): ()	
	globalGameProcessed = gameProcessed
	
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2) and not globalGameProcessed and Character then
		local moveValueInChar = Character:FindFirstChild("isDiscWalking")
		
		local mouseTarget = Mouse.Target
		local isValid = checkIfValid(true)
		
		if not moveValueInChar then
			return
		end
		
		if mouseTarget and isValid then
			onMoveToFinished()
			
			local mouseHit = Mouse.Hit.Position		
			Humanoid:MoveTo(mouseHit)
			
			moveValueInChar.Value = true
			Protocols.DiscWalking:FireServer(true)
			
			currentDiscMoveTo = CreateGreenDisc()
			Mouse.TargetFilter = currentDiscMoveTo
			
			currentDiscMoveTo.Name = "GreenDisc_Copy"
			currentDiscMoveTo.Adornee = workspace.Terrain
			currentDiscMoveTo.Visible = true
			currentDiscMoveTo.CFrame = CFrame.new(mouseHit) * CFrame.Angles(math.pi / 2, 0, 0)
			currentDiscMoveTo.Parent = workspace.CurrentCamera
		end
	end
end

--RunService.RenderStepped:Connect(DebugUpdate)
UserInputService.InputBegan:Connect(UserInputEquipItem)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.ButtonL1 then
			GamepadSelection -= 1
			GamepadSelection = math.clamp(GamepadSelection, 1, #Tools)
			
			FrameEquipEvent(GamepadSelection)
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
			GamepadSelection += 1
			GamepadSelection = math.clamp(GamepadSelection, 1, #Tools)
			
			FrameEquipEvent(GamepadSelection)
		end
	end
end)

MainGui.RedHealthbarFill.Visible = not Solo.Value

CursorUpdate()
UserInputService.InputChanged:Connect(CursorUpdate)

if Solo.Value or (not Chat:CanUserChatAsync(LocalPlayer.UserId)) then
	script.Parent.Backpack.Position = UDim2.new(0, 0, 1, 0)
end

-- A mobile fix since the mouse icon doesn't update properly on a single tap
if isMobile then
	UserInputService.InputBegan:Connect(CursorUpdate)
end

if not Character then
	Character = LocalPlayer.CharacterAdded:Wait()
end

LocalPlayer:WaitForChild("Backpack").ChildAdded:Connect(ToolChildAdded)
LocalPlayer:WaitForChild("Backpack").ChildRemoved:Connect(ToolChildRemoved)

for _, v in ipairs(LocalPlayer:WaitForChild("Backpack"):GetChildren()) do
	if v:IsA("Tool") then
		ToolChildAdded(v)
	end
end

if Character then
	Character.ChildAdded:Connect(ToolChildAdded)
	Character.ChildRemoved:Connect(ToolChildRemoved)

	for _, v in ipairs(Character:GetChildren()) do
		if v:IsA("Tool") then
			ToolChildAdded(v)
		end
	end

	if not Humanoid then
		Humanoid = Character:WaitForChild("Humanoid")
	end

	if (not isMobile) and Humanoid then
		canGreenDisc = true

		RunService.Heartbeat:Connect(greenDiskMain)
		UserInputService.InputBegan:Connect(clickToMoveMainInput)
		
		Humanoid.MoveToFinished:Connect(onMoveToFinished)
		Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(onMoveToFinished)
		Humanoid.Died:Connect(onMoveToFinished)
	end

	Humanoid.HealthChanged:Connect(Healthbar)
end