--!strict
--[[
	FWM 2022
	
	Handles initializing the graphics pipeline.
	GAMES UNITE!!! GAME UNITE!!!!!!
	
	TODO: Handle shape changing in surfaces script
]]

--Init:
local Humanoid = require(script.Humanoid)
local Explosions = require(script.Explosions)
local Surfaces = require(script.Surfaces)
local SkyElements = require(script.SkyElements)
local Replacements = require(script.Replacements)

--Functions:
local function Process(Child: any): ()
	if Child:IsA("BasePart") then
		Surfaces:ApplySurfaceTextures(Child)	
		Replacements:TintColor(Child)
		Replacements:HeadHumanoidCheck(Child)
	elseif Child:IsA("Humanoid") then
		Humanoid:ApplyHealthBar(Child)
		Replacements:Unbevel(Child.Parent)
	elseif Child:IsA("Explosion") then
		Explosions:OldifyExplosion(Child)
	elseif Child:IsA("SpecialMesh") then
		Replacements:HeadMesh(Child)
	elseif Child:IsA("Decal") then
		Replacements:OldifyTexture(Child)
	elseif Child:IsA("Sound") then
		Replacements:OldifySound(Child)
	end
end

--Hookup:
SkyElements:InitializeElements()

for _, v in pairs(workspace:GetDescendants()) do
	Process(v)
end

workspace.DescendantAdded:Connect(function(Child : any): ()
	Process(Child)
end)