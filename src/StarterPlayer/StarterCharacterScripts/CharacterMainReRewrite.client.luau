local Debris: Debris = game:GetService("Debris")
local GuiService: GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local TweenService: TweenService = game:GetService("TweenService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

---- Objects
local self = Players.LocalPlayer
local Figure = self.Character or self.CharacterAdded:Wait()
local hum = Figure:WaitForChild("Humanoid")
local torso = Figure:WaitForChild("Torso")
local head = Figure:WaitForChild("Head")
local protocols = ReplicatedStorage:WaitForChild("Protocols")
--local animate = Figure:WaitForChild("Animate", 1)

local paramsIgnore = RaycastParams.new()
paramsIgnore.RespectCanCollide = true

local ignore = {Figure}

---- Script variables
local lastJump = 0
local bounceCooldown = 0
local currentState = "Running"
local Jumped = false
local Grounded = false

---- silly things
local wait = task.wait
local spawn = task.spawn
local delay = task.delay

hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
---- Other
local connections = {}
local climblift : BodyVelocity
local ForceRotation : BodyGyro
local climbcon : RBXScriptConnection?
local movedircon : RBXScriptConnection?
local discwalkingcon : RBXScriptConnection?
local isDiscWalking : BoolValue
local isClimbing : BoolValue

-- do not look here
local DumbTables = {
	NOPESTATES = {
		PlatformStanding = true;
		FallingDown = true;
		Seated = true;
		Dead = true;
	};
	
	cantclimb = {
		FallingDown = true;
		GettingUp = true;
		Seated = true;
		Dead = true;
	};
	
	thenotjump = {
		Freefall = true;
		Jumping = true;
	};
};

local inf = TweenInfo.new(0.27, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local infSlow = TweenInfo.new(0.587, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local hheight0 = TweenService:Create(hum,infSlow, {HipHeight = 0})
local hheight0Slow = TweenService:Create(hum, infSlow, {HipHeight = 0})

local XZ = Vector3.new(1, 0, 1)

---- Localized globals (whatever this is for but i think it helps X X DDDD DDD)
local CFAng, CFNew = CFrame.Angles, CFrame.new
local abs, pi = math.abs, math.pi
local tableinsert = table.insert
local Vector3new = Vector3.new
local workspace = workspace
local tick = tick

---- Some functions
local function SafeUnit(unit: Vector3, CustomReturn: Vector3) : Vector3
	if (unit.Magnitude > 0) then
		return unit.Unit;
	end
	return CustomReturn or Vector3.zero;
end

local function Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function create(class: string, parent: Instance?, props: {[string] : any})
	local success : boolean, instance = pcall(function()
		return Instance.new(class)
	end)

	if success == true then
		if typeof(props) == "table" then
			for prop, val in pairs(props) do
				pcall(function()
					instance[prop] = val
				end)
			end
		end

		if typeof(parent) == "Instance" then
			instance.Parent = parent
		end

		return instance
	else
		warn(instance) -- x        d
	end

	return nil
end

-- D:
climblift = create("BodyVelocity", nil, {Name = "ClimbLift", Velocity = Vector3.zero, MaxForce = Vector3new(25000, 25000, 25000), P = 100000})
ForceRotation = create("BodyGyro", nil, {Name = "MovementGyro", MaxTorque = Vector3new(0, 6e6, 0), Parent = torso, D = 200})

local function LandTilt()
	local anguVel : AngularVelocity = torso:FindFirstChild("TorsoAttach"):FindFirstChild("AngularTilt")

	if anguVel then
		local vector = CFNew(head.Position, head.Position + head.AssemblyLinearVelocity * Vector3new(1, 0, 1)).LookVector
		local test = head.CFrame:vectorToObjectSpace(vector).Unit
		vector = SafeUnit(test*XZ, -Vector3.zAxis)
		
		anguVel.Enabled = true
		anguVel.MaxTorque = 6e6
		anguVel.AngularVelocity = vector * (head.AssemblyLinearVelocity.Magnitude / 14)
		for i = 1, 3 do RunService.RenderStepped:Wait() end
		repeat wait(0.04)
			anguVel.MaxTorque = Lerp(anguVel.MaxTorque, 0, 0.4)
			anguVel.AngularVelocity = anguVel.AngularVelocity:Lerp(Vector3.zero, 0.6)
		until anguVel.MaxTorque <= 100 or (currentState == "FallingDown")
		anguVel.MaxTorque = 0
		anguVel.AngularVelocity = Vector3.zero
		anguVel.Enabled = false
	end
end

local lastBounce = 0
local function Bounce()
	bounceCooldown = tick()
	local VerticalSpd = torso.AssemblyLinearVelocity.Y
	local HorizontalVelocity = torso.AssemblyLinearVelocity * Vector3new(1, 0, 1)
	local TargetVelocity = Vector3.zero

	if (VerticalSpd < 0) == false then return end

	if abs(VerticalSpd) >= 85 then
		local addToBounce = 0
		if os.clock() - lastBounce <= 1.3 then
			hum.HipHeight = -1.3
			wait()
			hheight0:Play()
			addToBounce = -1
		end

		repeat RunService.RenderStepped:Wait() until Grounded
		TargetVelocity = HorizontalVelocity + Vector3new(0, abs(VerticalSpd) / 1.25, 0)
		lastBounce = os.clock() + addToBounce
	end
	task.wait()
	hum:ChangeState(Enum.HumanoidStateType.Freefall)
	Jumped = false
	
	if TargetVelocity ~= Vector3.zero then
		torso.AssemblyLinearVelocity = TargetVelocity
	end
end

local function Raycast(origin : Vector3, direction : Vector3, params : RaycastParams)
	local RayResults = workspace:Raycast(origin, direction, params)

	if RayResults then
		local hit : BasePart? = RayResults.Instance
		local pos : Vector3 = RayResults.Position
		local normal : Vector3 = RayResults.Normal

		if hit and hit.CanCollide == false then
			tableinsert(ignore, hit)
			paramsIgnore.FilterDescendantsInstances = ignore
			return Raycast(origin, direction, params) -- game is kill
		end

		return hit, pos, normal
	end

	return nil
end

local function legfloat()
	local leg = (Figure:FindFirstChild("Right Leg") or Figure:FindFirstChild("Left Leg")) or nil
	hum.HipHeight = (leg ~= nil and 0 or 2)

	if leg then
		hheight0 = TweenService:Create(hum,infSlow, {HipHeight = 0})
		hheight0Slow = TweenService:Create(hum, infSlow, {HipHeight = 0})
	else
		hheight0 = TweenService:Create(hum, inf, {HipHeight = 2})
		hheight0Slow = TweenService:Create(hum, infSlow, {HipHeight = 2})
	end
end

local function TiltAngle(angle)
	return (torso.CFrame * CFAng(pi / 2, 0, 0)).LookVector.Y < angle
end

local function onTouchVelocity(hit : BasePart, touching : BasePart)
	local vel = hit.AssemblyLinearVelocity

	if vel.Magnitude >= 0.5 then
		touching.AssemblyAngularVelocity = touching.CFrame:VectorToObjectSpace(vel)
	end
end

local function ForceUpwards(speed)
	if tonumber(speed) and torso then
		for _, v : Instance in pairs(Figure:GetChildren()) do
			if v:IsA("BasePart") then
				v.AssemblyLinearVelocity = (v.AssemblyLinearVelocity * XZ) + speed
			end
		end
		
		local bv = Instance.new("BodyVelocity")
		bv.Name = "forcedSpeedUpwards"
		bv.Parent = torso
		bv.MaxForce = Vector3.yAxis*math.huge
		bv.Velocity = speed

		Debris:AddItem(bv, 0.0176715)
	end
end

local function ConnectTouchEvent(part : BasePart, functionToConnect)
	if part == nil then return nil end

	local con = part.Touched:Connect(function(hit)
		functionToConnect(hit, part)
	end)

	tableinsert(connections, con)
	return con
end

local alreadyKilled = false
local function Kill()
	if alreadyKilled == true then 
		return
	end
	alreadyKilled = true

	-- Clear connections
	for i in pairs(connections) do
		connections[i]:Disconnect()
		connections[i] = nil
	end
	
	if climbcon then climbcon:Disconnect() climbcon = nil end
	
	-- Sets "climblift" to nil if it is in the player still
	climblift.Parent = nil

	-- Disconnect physics update
	RunService:UnbindFromRenderStep("StankyPhysics")
end

local function CheckReflectPoint(where : Part, offset : Vector3?)
	local HorizontalVelocity = (where.AssemblyLinearVelocity * Vector3new(1, 0, 1))
	local velocityDot = where.CFrame.LookVector:Dot(HorizontalVelocity.Unit)
	local rayLength = 2 - (where.CFrame.LookVector:Dot(HorizontalVelocity.Unit) / 1.3)
	local hit, pos, nor = Raycast(where.Position, (HorizontalVelocity.Unit * rayLength) + (offset or Vector3.zero), paramsIgnore)
	local reflectedNormal = nil

	if hit then
		reflectedNormal = HorizontalVelocity.Unit - (2 * HorizontalVelocity.Unit:Dot(nor) * nor)
	end

	return reflectedNormal
end

-------- Main code
paramsIgnore.FilterDescendantsInstances = ignore

local gyro = Instance.new("BodyGyro")
gyro.Name = "GyroSlowedDownStanding"
gyro.CFrame = CFrame.new(torso.CFrame.LookVector)
gyro.D = 335
gyro.P = 2555
gyro.MaxTorque = Vector3.new(4e4, 0, 4e4)
gyro.Parent = Figure.Head

--- Create connections
ConnectTouchEvent(torso, onTouchVelocity)
ConnectTouchEvent(head, onTouchVelocity)
ConnectTouchEvent(Figure:FindFirstChild("Right Arm"), onTouchVelocity)
ConnectTouchEvent(Figure:FindFirstChild("Left Arm"), onTouchVelocity)


tableinsert(connections, hum.StateChanged:Connect(function(old, new)
	old, new = old.Name, new.Name
	currentState = new

	if new == "Dead" then
		Kill()
		return
	end

	if new == "Landed" then
		if tick() - bounceCooldown >= 1 then
			spawn(Bounce)
		end
		return
	elseif new == "GettingUp" then
		ForceUpwards(Vector3new(0, math.random(30, 50), 0))
	end

	if new == "Jumping" then
		lastJump = tick()
		Jumped = true
		return
	elseif not DumbTables.thenotjump[new] and Jumped == true then
		Jumped = false
		return
	end
end))

tableinsert(connections, Figure.ChildAdded:Connect(legfloat))
tableinsert(connections, Figure.ChildRemoved:Connect(legfloat))

tableinsert(connections, UserInputService.InputBegan:Connect(function(i, p) 
	if p or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return end
	local key = i.KeyCode

	if key == Enum.KeyCode.Space then
		if currentState == "Freefall" and Jumped == false and hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) == true then
			Jumped = true

			--if animate then
			--	animate.ForcePose:Fire("Jumping")
			--end
		end
	end
end))

--- Loops (and some dumb funcs)

local function VisualizeRaycast(raypos)
	task.spawn(function()
		local p = create("Part", nil, {Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false, Position = raypos, BrickColor = BrickColor.Green(), Shape = Enum.PartType.Ball, TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth, Size = Vector3new(0.5, 0.5, 0.5), Parent = workspace})
	
		task.wait(5)
	
		p:Destroy()
	end)
end

local ForceRotationLook = CFrame.lookAt(torso.Position, torso.Position + torso.CFrame.LookVector)
local dontforcerotationlook = false

local function updatePhys(dt : number)
	local TorsoP = torso.Position
	local HorizontalVelocity = (torso.AssemblyLinearVelocity * XZ)
	local VerticalSpeed = torso.AssemblyLinearVelocity.Y
	local hasTool = Figure:FindFirstChildOfClass("Tool")
	local GroundPart, GroundPosition, GroundNormal = Raycast(torso.Position, Vector3.yAxis*-3.05, paramsIgnore)
	local DiscWalking = (isDiscWalking and isDiscWalking.Value)
	Grounded = (GroundPart ~= nil)
	
	if tick() - lastJump >= 1 then
		hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	else
		hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end

	if (currentState == "Jumping" or currentState == "Freefall") and Jumped == true then
		hum.AutoRotate = false
	else
		hum.AutoRotate = true
	end

	-- Trip when tilted to some angle
	if TiltAngle(0.6) and (currentState == "Freefall" or currentState == "Running") then
		--if hum:GetState().Name ~= "FallingDown" then
		hum:ChangeState(Enum.HumanoidStateType.FallingDown)
		--end
	end

	-- other physics thing
	if DumbTables.NOPESTATES[currentState] then
		if gyro.MaxTorque ~= Vector3.zero then
			gyro.MaxTorque = Vector3.zero
			for _, v in pairs(torso:GetConnectedParts()) do
				v.AssemblyAngularVelocity = Vector3.zero
			end
		end
	else
		gyro.MaxTorque = XZ*4e4
	end

	-- :)
	if (currentState == "Running" or currentState == "Freefall") and (not DiscWalking) then
		if currentState == "Running" or (currentState == "Freefall" and Jumped == false) then
			dontforcerotationlook = false
			ForceRotationLook = CFrame.lookAt(torso.Position, torso.Position + (hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or torso.CFrame.LookVector))
		elseif currentState == "Freefall" and Jumped == true then
			if dontforcerotationlook == false then
				dontforcerotationlook = true
				ForceRotationLook = CFrame.lookAt(torso.Position, torso.Position + torso.CFrame.LookVector)
			else
				torso.AssemblyAngularVelocity = Vector3.zero
			end
		end
		ForceRotation.CFrame = ForceRotationLook
		ForceRotation.MaxTorque = Vector3.yAxis*5e5
	else
		ForceRotation.MaxTorque = Vector3.zero
	end

	--for _, part in region do
	--	if (part.CanCollide) then
			
	--	end
	--end

	--if currentState == "Climbing" then
		
	--	if Figure:FindFirstChild("Left Arm") then
	--		Figure["Left Arm"].CanCollide = false
	--	end

	--	if Figure:FindFirstChild("Right Arm") then
	--		Figure["Right Arm"].CanCollide = false
	--	end
		
	--	local yes = (hum.MoveDirection * hum.WalkSpeed)
	--	torso.AssemblyLinearVelocity =  Vector3new(yes.X, torso.AssemblyLinearVelocity.Y, yes.Z)
		
	--end
end

-- something nobonet couldn't do #roasted
-- ok may b this was kinda heavily inspired by retroblox climb code (dw we were allowed to use by ayray)
local function handleClimbing(dt)
	local direction = hum.MoveDirection
	local raycount = 0
	local outside = false
	
	if (not torso) then
		if climbcon then
			climbcon:Disconnect()
			climbcon = nil
		end
		
		climblift.Parent = nil
		
		return
	end
	
	local angul = torso:FindFirstChild("TorsoAttach"):FindFirstChild("AngularTilt")

	for i = 1, 12 do
		local lookVec = torso.CFrame.LookVector
		local origin = Vector3.new(torso.Position.X, torso.Position.Y - 0.8, torso.Position.Z)
		
		local cast, pos = Raycast(origin + Vector3.new(0, -2.25 + (i * 0.255), 0), lookVec, paramsIgnore)

		if cast then
			if not outside then
				outside = true
				raycount += 1
			end
		elseif outside then
			outside = false
			raycount += 1
		end
	end
	
	if raycount > 1 and (not angul.Enabled) and (not DumbTables.cantclimb[currentState]) and (not Jumped) then		
		local velocityBy = (isDiscWalking and isDiscWalking.Value) 
			and Vector3.new(torso.AssemblyLinearVelocity.X, hum.WalkSpeed * 0.7, torso.AssemblyLinearVelocity.Z) 
				or Vector3.new(direction.X * hum.WalkSpeed, hum.WalkSpeed * 0.7, direction.Z * hum.WalkSpeed)
		
		if not climblift.Parent then
			climblift.Parent = torso
			
			if isClimbing then
				isClimbing.Value = true
				protocols.Climbing:FireServer(true)
			end
		end
		
		climblift.Velocity = velocityBy
	elseif climblift.Parent then
		climblift.Parent = nil
		
		if isClimbing then
			isClimbing.Value = false
			protocols.Climbing:FireServer(false)
		end
	end
end

local function moveDirectionChanged()
	if ((isDiscWalking and isDiscWalking.Value) or hum.MoveDirection ~= Vector3.zero) and torso then
		if climbcon then
			return
		end
		
		climbcon = RunService.RenderStepped:Connect(handleClimbing)
	else
		if climbcon then
			climbcon:Disconnect()
			climbcon = nil
		end
		
		if climblift.Parent and isClimbing then
			isClimbing.Value = false
			protocols.Climbing:FireServer(false)
		end
		
		climblift.Parent = nil
	end
end

-- I am aware of the other ChildAdded call for the Figure, but I don't give a fart
local function childAddedToChar(child)
	local isDiscWalk = child:GetAttribute("FWMDiscWalk")
	local isClimb = child:GetAttribute("FWMClimb")
	
	if child:IsA("BoolValue") then
		if isDiscWalk then
			isDiscWalking = child
			tableinsert(connections, isDiscWalking:GetPropertyChangedSignal("Value"):Connect(moveDirectionChanged))
		elseif isClimb then
			isClimbing = child
		end
		
		if (isDiscWalking and isClimbing) and discwalkingcon then
			discwalkingcon:Disconnect()
			discwalkingcon = nil
		end
	end
end

RunService:BindToRenderStep("StankyPhysics", Enum.RenderPriority.Character.Value + 1, updatePhys)
tableinsert(connections, hum:GetPropertyChangedSignal("MoveDirection"):Connect(moveDirectionChanged))

discwalkingcon = Figure.ChildAdded:Connect(childAddedToChar)
tableinsert(connections, discwalkingcon)

--Hat system prototype:
game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameProcessedEvent)
	if not gameProcessedEvent then
		if inputObject.KeyCode == Enum.KeyCode.Equals then
			protocols:WaitForChild("Drop"):FireServer()
		end
	end
end)