local Player = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentPlayer = Player:GetPlayerFromCharacter(script.Parent)

local bodyPartColors = {
	["Head"] = BrickColor.new(24),
	["Left Arm"] = BrickColor.new(26),
	["Right Arm"] = BrickColor.new(26),
	["Left Leg"] = BrickColor.new(26),
	["Right Leg"] = BrickColor.new(26)
}

local function onTeamChanged()
	if not CurrentPlayer then
		return
	end
	
	task.wait(1)
	
	local character = script.Parent
	
	if CurrentPlayer.Neutral then
		local oldBodyColors = character:FindFirstChild("Body Colors")
		
		if oldBodyColors then
			oldBodyColors:Clone().Parent = character
			oldBodyColors:Destroy()
		end
	else
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("Part") and bodyPartColors[v.Name] then
				v.BrickColor = bodyPartColors[v.Name]
			end
		end
		
		local hasTorso = character:FindFirstChild("Torso")
		
		if hasTorso then
			hasTorso.BrickColor = CurrentPlayer.Team.TeamColor
		end
	end
end

CurrentPlayer:GetPropertyChangedSignal("Neutral"):Connect(onTeamChanged)
CurrentPlayer:GetPropertyChangedSignal("TeamColor"):Connect(onTeamChanged)

onTeamChanged()