--!strict
--[[
	FWM Official, 2022
	
	This will handle stuff like the scrolling sound and stuff idk
	-- KeyboardCombination
]]
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
--local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local UserInputService: UserInputService = game:GetService("UserInputService")

--GuiService.AutoSelectGuiEnabled = false

local CustomFont = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CustomFont"))
local StockSound = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("StockSound"))

local MAX_RETRIES: number = 8

local cameraKeys = {
	[Enum.KeyCode.Comma] = true,
	[Enum.KeyCode.I] = true,
	[Enum.KeyCode.O] = true,
	[Enum.KeyCode.PageDown] = true, 
	[Enum.KeyCode.PageUp]= true,
	[Enum.KeyCode.Period] = true,
}

local function cameraSound(input: InputObject, gameProcessedEvent: boolean): ()
	if not gameProcessedEvent and UserInputService:GetFocusedTextBox() == nil then
		if input.UserInputType == Enum.UserInputType.MouseWheel or cameraKeys[input.KeyCode] then
			StockSound:PlaySoundLocal("Step")
		end
	end
end

-- disable reset button (from developer forum):
local function coreCall(method, ...)
	local result = {}
	
	for retries = 1, MAX_RETRIES do
		result = {pcall(StarterGui[method], StarterGui, ...)}
		
		if result[1] then
			break
		end
		
		local deltaTime: number = RunService.Heartbeat:Wait()
	end
	
	return unpack(result)
end

local function renderFont(ins: Instance): ()
	if ins:IsA("TextLabel") and ins.FontFace.Family == "rbxasset://fonts/families/GothamSSm.json" then
		ins.Font = Enum.Font.Cartoon
		ins.TextSize += 2
	end
end

coreCall("SetCore", "ResetButtonCallback", false)
-- if this causes havoc, assert() it again

for _, v in pairs(script.Parent:WaitForChild("MainGui"):GetDescendants()) do
	renderFont(v)
end

for _, v in pairs(script.Parent:WaitForChild("MainResetGui"):GetDescendants()) do
	renderFont(v)
end

script.Parent:WaitForChild("MainGui").DescendantAdded:Connect(renderFont)
script.Parent:WaitForChild("MainResetGui").DescendantAdded:Connect(renderFont)

UserInputService.InputChanged:Connect(cameraSound)
UserInputService.InputBegan:Connect(cameraSound)