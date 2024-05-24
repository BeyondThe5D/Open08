local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local HttpsService = game:GetService("HttpService")

local IsSolo = ReplicatedStorage:WaitForChild("Solo")
local GameServerId = HttpsService:GenerateGUID(false) -- could've used JobId, but tbh this looks cooler

local Message

local function UpdateCount()
	local PlayerCount = #Players:GetPlayers()

	local Success, Errored = pcall(function()
		Message = MessagingService:PublishAsync("PlayersOnline", {
			GameId = game.PlaceId,
			ServerId = GameServerId,
			PlayersOnline = PlayerCount,
		})
	end)

	if PlayerCount <= 0 then
		if Message then
			Message:Disconnect()
			Message = nil
		end
	end
	
	if Success then
		print("Data sent!")
	end
end

if game.PrivateServerId == "" and not RunService:IsStudio() then
	game:BindToClose(function()
		UpdateCount()
	end)

	while task.wait(25) do
		UpdateCount()
	end
else
	print("Cannot update count in solo!")
end