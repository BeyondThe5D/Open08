-- Roblox character sound script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SOUND_DATA = {
	Climbing = {
		SoundId = "rbxassetid://12221952",
		Looped = true,
	},
	Died = {
		SoundId = "rbxassetid://1033209269",
		TimePosition = 0.35,
	},
	FreeFalling = {
		SoundId = "",
		Looped = true,
	},
	GettingUp = {
		SoundId = "rbxassetid://12222046",
	},
	Jumping = {
		SoundId = "rbxassetid://12221967",
	},
	Running = {
		SoundId = "rbxassetid://12221952",
		Looped = true,
	},
	PlatformStand = {
		SoundId = "rbxassetid://12222152"
	}
}

-- wait for the first of the passed signals to fire
local function waitForFirst(...)
	local shunt = Instance.new("BindableEvent")
	local slots = {...}

	local function fire(...)
		for i = 1, #slots do
			slots[i]:Disconnect()
		end

		return shunt:Fire(...)
	end

	for i = 1, #slots do
		slots[i] = slots[i]:Connect(fire)
	end

	return shunt.Event:Wait()
end

-- map a value from one range to another
local function map(x, inMin, inMax, outMin, outMax)
	return (x - inMin)*(outMax - outMin)/(inMax - inMin) + outMin
end

local function playSound(sound)
	if sound.SoundId == "rbxassetid://1033209269" then
		sound.TimePosition = 0.35
	else
		sound.TimePosition = 0
	end
	sound.Playing = true
end

local function shallowCopy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

local function initializeSoundSystem(player, humanoid, rootPart)
	local sounds = {}

	-- initialize sounds
	for name, props in pairs(SOUND_DATA) do
		local sound = Instance.new("Sound")
		-- sound.Name = name

		-- set default values
		-- sound.Archivable = false
		-- sound.EmitterSize = 5
		-- sound.MaxDistance = 150
		-- sound.Volume = 0.65

		for propName, propValue in pairs(props) do
			sound[propName] = propValue
		end

		sound.Parent = rootPart
		sounds[name] = sound
	end

	local playingLoopedSounds = {}

	local function stopPlayingLoopedSounds(except)
		for sound in pairs(shallowCopy(playingLoopedSounds)) do
			if sound ~= except then
				sound.Playing = false
				playingLoopedSounds[sound] = nil
			end
		end
	end

	-- state transition callbacks
	local stateTransitions = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds()
		end,

		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.GettingUp)
		end,
		
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.PlatformStand)
		end,
		
		[Enum.HumanoidStateType.PlatformStanding] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.PlatformStand)
		end,

		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.Jumping)
			task.wait(.05)
			sounds.Jumping.Playing = false
		end,

		[Enum.HumanoidStateType.Running] = function()
			stopPlayingLoopedSounds(sounds.Running)
			sounds.Running.Playing = true
			playingLoopedSounds[sounds.Running] = true
		end,

		[Enum.HumanoidStateType.Climbing] = function()
			local sound = sounds.Climbing
			if math.abs(rootPart.AssemblyLinearVelocity.Y) > 0.1 then
				sound.Playing = true
				stopPlayingLoopedSounds(sound)
			else
				stopPlayingLoopedSounds()
			end
			playingLoopedSounds[sound] = true
		end,

		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds()
		end,

		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds()
			playSound(sounds.Died)
		end,
	}

	-- updaters for looped sounds
	local loopedSoundUpdaters = {
		[sounds.Climbing] = function(dt, sound, vel)
			sound.Playing = vel.Magnitude > 0.1
		end,

		[sounds.FreeFalling] = function(dt, sound, vel)
			if vel.Magnitude > 75 then
				sound.Volume = math.clamp(sound.Volume + 0.9*dt, 0, 1)
			else
				sound.Volume = 0
			end
		end,

		[sounds.Running] = function(dt, sound, vel)
			sound.Playing = vel.Magnitude > 0.5 and humanoid.MoveDirection.Magnitude > 0.5
		end,
	}

	-- state substitutions to avoid duplicating entries in the state table
	local stateRemap = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running,
	}

	local activeState = stateRemap[humanoid:GetState()] or humanoid:GetState()

	if activeState ~= Enum.HumanoidStateType.None and stateTransitions[activeState]  then
		stateTransitions[activeState]()
	end

	local stateChangedConn = humanoid.StateChanged:Connect(function(_, state)
		state = stateRemap[state] or state

		if state ~= activeState then
			local transitionFunc = stateTransitions[state]

			if transitionFunc then
				transitionFunc()
			end

			activeState = state
		end
	end)

	local steppedConn = RunService.Stepped:Connect(function(time, deltaTime)
		-- update looped sounds on stepped
		for sound in pairs(playingLoopedSounds) do
			local updater = loopedSoundUpdaters[sound]

			if updater then
				updater(deltaTime, sound, rootPart.AssemblyLinearVelocity)
			end
		end
	end)

	local humanoidAncestryChangedConn
	local rootPartAncestryChangedConn
	local characterAddedConn

	local function terminate()
		stateChangedConn:Disconnect()
		steppedConn:Disconnect()
		humanoidAncestryChangedConn:Disconnect()
		rootPartAncestryChangedConn:Disconnect()
		characterAddedConn:Disconnect()
	end

	humanoidAncestryChangedConn = humanoid.AncestryChanged:Connect(function(_, parent)
		if not parent then
			terminate()
		end
	end)

	rootPartAncestryChangedConn = rootPart.AncestryChanged:Connect(function(_, parent)
		if not parent then
			terminate()
		end
	end)

	characterAddedConn = player.CharacterAdded:Connect(terminate)
end

local function playerAdded(player)
	local function characterAdded(character)
		-- Avoiding memory leaks in the face of Character/Humanoid/RootPart lifetime has a few complications:
		-- * character deparenting is a Remove instead of a Destroy, so signals are not cleaned up automatically.
		-- ** must use a waitForFirst on everything and listen for hierarchy changes.
		-- * the character might not be in the dm by the time CharacterAdded fires
		-- ** constantly check consistency with player.Character and abort if CharacterAdded is fired again
		-- * Humanoid may not exist immediately, and by the time it's inserted the character might be deparented.
		-- * RootPart probably won't exist immediately.
		-- ** by the time RootPart is inserted and Humanoid.RootPart is set, the character or the humanoid might be deparented.

		if not character.Parent then
			waitForFirst(character.AncestryChanged, player.CharacterAdded)
		end

		if player.Character ~= character or not character.Parent then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		while character:IsDescendantOf(game) and not humanoid do
			waitForFirst(character.ChildAdded, character.AncestryChanged, player.CharacterAdded)
			humanoid = character:FindFirstChildOfClass("Humanoid")
		end

		if player.Character ~= character or not character:IsDescendantOf(game) then
			return
		end

		-- must rely on HumanoidRootPart naming because Humanoid.RootPart does not fire changed signals
		local rootPart = character:FindFirstChild("Head")
		while character:IsDescendantOf(game) and not rootPart do
			waitForFirst(character.ChildAdded, character.AncestryChanged, humanoid.AncestryChanged, player.CharacterAdded)
			rootPart = character:FindFirstChild("Head")
		end

		if rootPart and humanoid:IsDescendantOf(game) and character:IsDescendantOf(game) and player.Character == character then
			initializeSoundSystem(player, humanoid, rootPart)
		end
	end

	if player.Character then
		characterAdded(player.Character)
	end
	player.CharacterAdded:Connect(characterAdded)
end

Players.PlayerAdded:Connect(playerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	playerAdded(player)
end