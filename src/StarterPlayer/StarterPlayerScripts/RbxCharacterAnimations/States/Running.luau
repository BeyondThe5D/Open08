local function is_climbing(this)
	--local direction = this.humanoid.MoveDirection;
	--local cframe = this.torso.CFrame;
	--local origin = cframe * CFrame.new(direction - Vector3.yAxis*1.75);
	--local right = origin*Vector3.new(1,1,0.5);
	--local left = origin*Vector3.new(-1,-1,-0.5);
	
	--local region = workspace:FindPartsInRegion3WithIgnoreList(Region3.new(left:Min(right), left:Max(right)), {this.character});
	--for _, part in region do
	--	if (part.CanCollide)then
	--		return true;
	--	end
	--end
	
	-- ! Find First Child
	local hasclimb: Instance = this.climbvalue
	
	if hasclimb and hasclimb:IsA("BoolValue") and hasclimb.Value then
		return true
	end
end

return function(this, dt)
	if(is_climbing(this))then
		return this.states.Climbing(this, dt);
	end
	
	local rsh = this.RightShoulder;
	local lsh = this.LeftShoulder;	
	rsh.MaxVelocity = 0.15/2;
	lsh.MaxVelocity = 0.15/2;
	this.RightHip.MaxVelocity = 0.15/2
	this.LeftHip.MaxVelocity = 0.15/2
	
	local direction = this.humanoid.MoveDirection;
	
	local ismoving = (0 < direction:Dot(direction) or (this.discwalking and this.discwalking.Value))
	local angle = ismoving and math.sin(os.clock()*9) or 0.1 * math.sin(os.clock());
	
	this.RightHip.DesiredAngle = -angle;
	this.LeftHip.DesiredAngle = -angle;
	rsh.DesiredAngle = angle;
	lsh.DesiredAngle = angle;
	
	this:update_tool(dt);
end