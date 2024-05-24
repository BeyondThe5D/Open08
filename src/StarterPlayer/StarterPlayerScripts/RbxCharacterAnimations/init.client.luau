local ReplicatedStorage = game:GetService("ReplicatedStorage");
--local AnimationsThing = ReplicatedStorage:WaitForChild("Protocols"):WaitForChild("GetSetting"):InvokeServer("Animations");

--if (not AnimationsThing) then
--	script:Destroy()
--	return
--end

local PlayerService = game:GetService("Players");
local RunService = game:GetService("RunService");

local Players = {};

local Character = require(script.Character);
local function disconnect(this)
	Players[this] = nil;
end

local function characterAdded(model)
	local character = Character.new(model);
	character.disconnect = disconnect;
	character.updated = 0;
	character:change_state("Running");
	Players[character] = true;
end

local function playerAdded(player)
	player.CharacterAdded:Connect(function()
		coroutine.wrap(characterAdded)(player.Character);
	end)
	
	if(player.Character)then
		coroutine.wrap(characterAdded)(player.Character);
	end
end

local character; --what is this for

RunService.Heartbeat:Connect(function(dt)
	for character in Players do
		character:update(dt);
	end
end)

for _, player in PlayerService:GetPlayers() do
	playerAdded(player);
end

PlayerService.PlayerAdded:Connect(playerAdded);