return function(this, dt)
	local rsh=this.RightShoulder;
	local lsh=this.LeftShoulder;
	rsh.MaxVelocity = 0.5/2;
	lsh.MaxVelocity = 0.5/2;
	rsh.DesiredAngle = -3.14;
	lsh.DesiredAngle = 3.14;
	
	this.RightHip.DesiredAngle = 0;
	this.LeftHip.DesiredAngle = 0;
	--this:update_tool(dt);
end