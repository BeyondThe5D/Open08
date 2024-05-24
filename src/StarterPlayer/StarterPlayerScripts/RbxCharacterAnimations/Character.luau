local Players = game:GetService("Players");
local States = {};
for _, state in script.Parent.States:GetChildren() do
	States[state.Name] = require(state);
end

local Character = {};
Character.__index = Character;

local all_motors = {
	"Right Shoulder";
	"Left Shoulder";
	"Right Hip";
	"Left Hip";
};
local function get_motors(where)
	local motors = {};
	local out = {};
	for _, name in all_motors do
		local motor = where:WaitForChild(name);
		local data = {
			MaxVelocity = 0.1;
			C0 = motor.C0;
			DesiredAngle = 0;
			CurrentAngle = 0;
		};
		motors[name:gsub(' ','')] = data;
		out[motor] = data;
	end
	return motors, out;
end

function Character.new(character)
	local env, motors = get_motors(character:WaitForChild("Torso"));
	env.character = character;
	env.states = States;
	env.motors = motors;
	return setmetatable(env, Character):init();
end

function Character:destroy()
	if(self.animConnection)then
		self.animConnection:Disconnect();
	end
	
	for _, conn in self.connections do
		conn:Disconnect();
	end
	
	self:disconnect();
end

local fmt = "%s is not a valid state";

function Character:change_state(to)
	if(not States[to])then
		return;
	end
	self.state = States[to];
	self.state(self, 0);
end

function Character:update_tool(dt)
	if(not self.tool)then
		return;
	end
	
	local toolAnim = self.toolAnim;
	if(self.toolClock<os.clock())then
		self.toolAnim="None";
		toolAnim="None";
	end
	
	--if(toolAnim == "None" and self.state ~= States.Climbing)then
	if(toolAnim == "None")then
		self.RightShoulder.DesiredAngle = 1.57;
		self.RightShoulder.MaxVelocity = 0.175/2;
	elseif(toolAnim == "Slash")then
		self.RightShoulder.MaxVelocity = 0.35/2;
		self.RightShoulder.DesiredAngle = 0;
	elseif(toolAnim == "Lunge")then
		local rsh=self.RightShoulder;
		local lsh=self.LeftShoulder;
		local rhp=self.RightHip;
		local lhp=self.LeftHip;
		rsh.MaxVelocity = 0.35/2;
		lsh.MaxVelocity = 0.35/2;
		rhp.MaxVelocity = 0.35/2;
		lhp.MaxVelocity = 0.35/2;
		rsh.DesiredAngle = 1.57;
		lsh.DesiredAngle = 1.0;
		rhp.DesiredAngle = 1.57;
		lhp.DesiredAngle = 1.0;
	end
end

function Character:init()
	local humanoid = self.character:WaitForChild("Humanoid");
	local discwalking = self.character:FindFirstChild("isDiscWalking");
	local climbingvalue = self.character:FindFirstChild("isClimbing");
	self.torso = self.character.Torso;
	self.toolClock = 0;
	self.humanoid = humanoid;
	self.discwalking = discwalking;
	self.climbvalue = climbingvalue;
	self.connections = {
		self.character.AncestryChanged:Connect(function()
			if(not self.character.Parent)then
				return;
			end
			self:destroy();
		end);
		
		self.character.ChildAdded:Connect(function(tool)
			if(tool:IsA("Tool")and tool:FindFirstChild("Handle"))then
				self.tool=tool;
				if(self.animConnection)then
					self.animConnection:Disconnect();
				end
				
				self.toolAnim = "None";
				self.animConnection = tool.ChildAdded:Connect(function(anim)
					if(anim:IsA("StringValue") and anim.Name=="toolanim")then
						self.toolAnim = anim.Value;
						self.toolClock = os.clock()+0.3;
						self:update(0);
					end
				end)
			end
			
			-- in the case the client doesn't detect the discWalking bool 1st time, this has happened before and I've been reported this issue
			--if (tool:IsA("BoolValue") and tool.Name == "isDiscWalking" and tool:GetAttribute("FWMDiscWalking")) and (not self.discwalking) then
			--	self.discwalking = tool
			--end
			
			if (tool:IsA("BoolValue")) then
				local isDisc = tool:GetAttribute("FWMDiscWalk")
				local isClimb = tool:GetAttribute("FWMClimb")
				
				if isDisc and (not self.discwalking) then
					self.discwalking = tool
				elseif isClimb and (not self.climbvalue) then
					self.climbvalue = tool
				end
			end
		end);
		
		self.character.ChildRemoved:Connect(function(tool)
			if(self.tool==tool)then
				if(self.animConnection)then
					self.animConnection:Disconnect();
				end
				self.tool=nil;
			end
		end);
		
		humanoid.Died:Connect(function()
			self:destroy();
		end);
		
		humanoid.StateChanged:Connect(function(prev, state)
			if (state.Name:match("Running") or not (prev.Name:match("Jumping"))) then
				self:change_state("Running");
			else
				self:change_state(state.Name);
			end
			
			self:update(0);
		end)
	};
	
	return self;
end

function Character:update(dt)
	self.state(self,dt);
	
	for motor, data in self.motors do
		local max = data.MaxVelocity*dt*60;
		data.CurrentAngle += math.clamp(data.DesiredAngle - data.CurrentAngle, -max, max);
		motor.C0 = data.C0 * CFrame.Angles(0,0,data.CurrentAngle);
	end
end

return Character;