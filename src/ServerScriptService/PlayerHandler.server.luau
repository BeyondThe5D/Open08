--[[
	Classic Roblox Clothes! 2022
	
	Handles loading characters, including loading character appearance.
]]
local AssetService: AssetService = game:GetService("AssetService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService: TeleportService = game:GetService("TeleportService")
local StarterGui: StarterGui = game:GetService("StarterGui")

local UI = ServerStorage:WaitForChild("UI")

local StarterGuis = UI:WaitForChild("StarterGui")

local Loaded = {}

local BodyParts: { [string] : string } = {
	["Head"] = "Head",
	["Torso"] = "Torso",
	["LeftArm"] = "Left Arm",
	["RightArm"] = "Right Arm",
	["LeftLeg"] = "Left Leg",
	["RightLeg"] = "Right Leg",
}

local function LoadCharacterAppearance(Player): ()
	local isClimbing = Instance.new("BoolValue")
	isClimbing.Name = "isClimbing"
	isClimbing.Value = false
	isClimbing:SetAttribute("FWMClimb", true)
	isClimbing.Parent = Player.Character

	local isDiscWalking = Instance.new("BoolValue")
	isDiscWalking.Name = "isDiscWalking"
	isDiscWalking.Value = false
	isDiscWalking:SetAttribute("FWMDiscWalk", true)
	isDiscWalking.Parent = Player.Character
end

-- returns the player object that killed this humanoid
-- returns nil if the killer is no longer in the game
function getKillerOfHumanoidIfStillInGame(humanoid)

	-- check for kill tag on humanoid - may be more than one - todo: deal with this
	local tag = humanoid:findFirstChild("creator")

	-- find player with name on tag
	if tag then
		local killer = tag.Value
		if killer.Parent then -- killer still in game
			return killer
		end
	end

	return nil
end

local function FixUIsFor2006(Player: Player): ()
	local PlayerGui = Player:FindFirstChild("PlayerGui")

	local findMainGui = PlayerGui:FindFirstChild("MainGui")
	local findMainResetGui = PlayerGui:FindFirstChild("MainResetGui")

	if findMainGui then
		findMainGui.Enabled = true
	end

	if findMainResetGui then
		findMainResetGui.Enabled = true
	end
end

local function GiveUIsToPlayer(Player: Player, GiveUIs: boolean): ()
	if (not GiveUIs) then
		return
	end

	task.defer(function()
		local PlayerGui = Player:FindFirstChild("PlayerGui")

		for _, obj in pairs(StarterGuis:GetChildren()) do
			local canGiveObj = obj:GetAttribute("DontGiveAgain")

			if (not (obj:IsA("ScreenGui") and (not obj.ResetOnSpawn))) and (not canGiveObj) then
				local clonedObject = obj:Clone()
				clonedObject.Parent = PlayerGui
			end
		end

		FixUIsFor2006(Player)
	end)
end

local function HandleDeath(Player: Player): ()
	if Player then	
		task.wait(Players.RespawnTime)

		if Player ~= nil then
			Player:LoadCharacter()
			--ReplicatedStorage:WaitForChild("Protocols"):WaitForChild("CharacterAdded"):FireAllClients(Player.CharacterAdded)
			--LoadCharacterAppearance(Player)
		end
	end
end

-- not an ideal thing at all, im just doing this so animations remain accurate
local function discWalkingFired(player: Player, value: boolean): ()
	local playerChar = player.Character
	local hasDiscValue = playerChar:FindFirstChild("isDiscWalking")

	if (not hasDiscValue) then
		return
	end

	hasDiscValue.Value = value
end

local function oldClimbFired(player: Player, value: boolean): ()
	local playerChar = player.Character
	local climbValue = playerChar:FindFirstChild("isClimbing")

	if (not climbValue) then
		return
	end

	climbValue.Value = value
end

local function loadForFirstTime(player: Player)
	local findLoaded = Loaded[player]
	local uiOnRespawn = false

	if not findLoaded then
		Loaded[player] = true

		task.wait(3)

		player.CharacterAdded:Connect(function(character)		
			LoadCharacterAppearance(player)
			GiveUIsToPlayer(player, uiOnRespawn)

			if (not uiOnRespawn) then
				uiOnRespawn = true
			end

			local humanoid = character:WaitForChild("Humanoid", 5)

			if humanoid then
				humanoid.Died:Connect(function()
					HandleDeath(player)
				end)
			end
		end)

		player:LoadCharacter()

		--ReplicatedStorage:WaitForChild("Protocols"):WaitForChild("CharacterAdded"):FireAllClients(player.Character)
		--LoadCharacterAppearance(player)

		print(player.Name .. " Loaded")

		local playerGui = player:FindFirstChildOfClass("PlayerGui")
		playerGui.Loading:Destroy()

		FixUIsFor2006(player)
	end
end

local function PlayerAdded(player: Player)	
	local playerUI = player:WaitForChild("PlayerGui")

	local Data = player:GetJoinData()

	for _, obj in pairs(StarterGuis:GetChildren()) do
		obj:Clone().Parent = playerUI
	end 

	--for _, obj in pairs(StarterGui:GetChildren()) do
	--	obj:Clone().Parent = playerUI
	--end
	--end

	--ServerStorage:WaitForChild("UI"):WaitForChild("Loading"):Clone().Parent = playerUI

	--ServerStorage:WaitForChild("UI"):WaitForChild("MainGui"):Clone().Parent = playerUI
	--ServerStorage:WaitForChild("UI"):WaitForChild("MainResetGui"):Clone().Parent = playerUI
end

local function hatDropServer(player: Player): ()
	local playerChar = player.Character

	if not playerChar then
		return
	end

	for _, obj in pairs(playerChar:GetChildren()) do
		if obj:IsA("Accoutrement") then
			obj.Parent = workspace
		end
	end
end

--local standardPages = AssetService:GetGamePlacesAsync()

--for _, Places in pairs(standardPages:GetCurrentPage()) do
--	table.insert(PlaceIDs, tonumber(Places.PlaceId))
--end

local LoadForFirstTime = Instance.new("RemoteEvent")
LoadForFirstTime.Name = "LoadForFirstTime"
LoadForFirstTime.OnServerEvent:Connect(loadForFirstTime)
LoadForFirstTime.Parent = ReplicatedStorage:WaitForChild("Protocols")

-- dumb fix for playerhandler being created after player exists
for _, Player in pairs(Players:GetPlayers()) do
	PlayerAdded(Player)
end

Players.PlayerAdded:Connect(PlayerAdded)

local DiscWalking = Instance.new("RemoteEvent")
DiscWalking.Name = "DiscWalking"
DiscWalking.OnServerEvent:Connect(discWalkingFired)
DiscWalking.Parent = ReplicatedStorage:WaitForChild("Protocols")
local Climbing = Instance.new("RemoteEvent")
Climbing.Name = "Climbing"
Climbing.OnServerEvent:Connect(oldClimbFired)
Climbing.Parent = ReplicatedStorage:WaitForChild("Protocols")

local Drop = Instance.new("RemoteEvent")
Drop.Name = "Drop"
Drop.OnServerEvent:Connect(hatDropServer)
Drop.Parent = ReplicatedStorage:WaitForChild("Protocols")

game:BindToClose(function()
	local message: Message = Instance.new("Message")
	message.Name = "FWM_SHUTDOWN_MESSAGE"
	message.Text = "Server shutting down..."
	message.Parent = workspace

	TeleportService.TeleportInitFailed:Connect(function(player: Instance, teleportResult: Enum.TeleportResult, errorMessage: string, placeId: number, teleportOptions: Instance): ()
		if player:IsA("Player") then
			player:Kick("Server shutdown, failed to send back to the menu.")
		end
	end)

	for _, v in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(17588164210, v, nil, nil)
	end
end)