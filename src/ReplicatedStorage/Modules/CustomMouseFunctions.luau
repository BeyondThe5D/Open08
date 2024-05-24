--[[
	Serves as a cross-platform activated module
	Note: PC is the only platform to support KeyUp and KeyDown
	https://create.roblox.com/docs/reference/engine/classes/Mouse
	
	Supports:
		- PC
		- Mobile
		- XBoxOne
		
	Initiation:
		local CustomMouseFunctions = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CustomMouseFunctions")):Init()
	
	Button1Down:
		Acts like Mouse.Button1Down, activates when the left mouse button goes down
	
		- CustomMouseFunctions:Button1Down(callback)
	
	Button1Up:
		Acts like Mouse.Button1Up, activates when the left mouse button goes up
	
		- CustomMouseFunctions:Button1Up(callback)
	
	KeyDown:
		Acts like Mouse.KeyDown, activates when a key is pressed down
		
		NOTES: 
			- This function returns the key pressed down
			- Only works on PC

		- CustomMouseFunctions:KeyDown(callback)
	
	KeyUp:
		Acts like Mouse.KeyUp, activates when a key is let go
		
		NOTES: 
			- This function returns the key that was just let go
			- Only works on PC
	
		- CustomMouseFunctions:KeyUp(callback)
	
	Move:
		Acts like Mouse.Move, activates when the mouse is moving
	
		- CustomMouseFunctions:Move(callback)
	
	Idle:
		Acts like Mouse.Idle, activates when the mouse is in idle
		- CustomMouseFunctions:Idle(callback)
--]]

local Players: Players = game:GetService("Players");
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")

local CustomCamera = require(script.Parent:WaitForChild("CustomCamera"));

local LocalPlayer = Players.LocalPlayer;
local Camera: Camera = workspace.CurrentCamera;
local Mouse: Mouse = LocalPlayer:GetMouse();

local CustomMouseFunctions = {}
CustomMouseFunctions.__index = CustomMouseFunctions

local fflagUseDefaultMouse = false;
function CustomMouseFunctions:Target(): any
	if(fflagUseDefaultMouse)then
		return Mouse.Target;
	end
	
	local params = RaycastParams.new();
	params.FilterType = Enum.RaycastFilterType.Exclude;
	params.FilterDescendantsInstances = {Mouse.TargetFilter};

	local unitRay = self:UnitRay();
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction*1000, params);
	local cf = CFrame.lookAt(Vector3.zero, unitRay.Direction);
	if(result)then
		return result.Instance, cf.Rotation + result.Position;
	else
		return nil, cf.Rotation + (unitRay.Origin+unitRay.Direction*1000);
	end
end

function CustomMouseFunctions:UnitRay(): Ray
	if(fflagUseDefaultMouse)then
		return Mouse.UnitRay;
	end

	local x = Mouse.X;
	local y = Mouse.Y+32;
	return CustomCamera:ViewportPointToWorld(x, y);
end

function CustomMouseFunctions:AddBillboard(billboard)
	table.insert(self.billboards, billboard);
end

function CustomMouseFunctions:Hit(): CFrame
	if(fflagUseDefaultMouse)then
		return Mouse.Hit;
	end

	local params = RaycastParams.new();
	params.FilterType = Enum.RaycastFilterType.Exclude;
	params.FilterDescendantsInstances = {Mouse.TargetFilter};
	
	local unitRay = self:UnitRay();
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction*1000, params);
	local cf = CFrame.lookAt(Vector3.zero, unitRay.Direction);
	if(result)then
		return cf + result.Position;
	else
		return cf + (unitRay.Origin+unitRay.Direction*1000);
	end
end

function CustomMouseFunctions:Init()	
	return CustomMouseFunctions
end

function CustomMouseFunctions:Button1Down(callback: () -> any): ()
	if not UserInputService.TouchEnabled then
		return UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean): ()
			if not gameProcessedEvent then
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then	
					return callback()
				end
			end
		end)
	else
		return UserInputService.TouchTapInWorld:Connect(function(position: Vector2, processedByUI: boolean): () -- we should RLY fix this ngl...
			if not processedByUI then	
				return callback()
			end
		end)
	end
end

function CustomMouseFunctions:Button1Up(callback: () -> any): ()
	return UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean): ()
		if not gameProcessedEvent then
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2 then
				return callback()
			end
		end
	end)
end

function CustomMouseFunctions:KeyDown(callback: (string) -> any)	
	if not UserInputService.TouchEnabled then
		return UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean): ()
			if not gameProcessedEvent then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					return callback(input.KeyCode.Name)
				end
			end
		end)
	end
end

function CustomMouseFunctions:KeyUp(callback: (string) -> any): ()
	if not UserInputService.TouchEnabled then
		return UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean): ()
			if not gameProcessedEvent then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					return callback(input.KeyCode.Name)
				end
			end
		end)
	end
end

function CustomMouseFunctions:Move(callback: () -> any): ()		
	return UserInputService.InputChanged:Connect(function(input: InputObject, gameProcessedEvent: boolean): ()
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and input.UserInputState == Enum.UserInputState.Change then
			return callback()
		end
	end)
end

function CustomMouseFunctions:Idle(callback: () -> any): ()
	local lastPosition: Vector2 = Vector2.zero

	return RunService.PostSimulation:Connect(function(deltaTimeSim: number): ()
		local currentPosition: Vector2 = UserInputService:GetMouseLocation()

		if currentPosition ~= lastPosition then
			lastPosition = currentPosition
		else
			return callback()
		end
	end)
end


return CustomMouseFunctions
