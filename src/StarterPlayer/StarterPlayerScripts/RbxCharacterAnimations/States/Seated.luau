return function(this, dt)
	local rsh = this.RightShoulder;
	local lsh = this.LeftShoulder;
	rsh.MaxVelocity = 0.5/2;
	lsh.MaxVelocity = 0.5/2;
	rsh.DesiredAngle = 3.14/2;
	lsh.DesiredAngle = -3.14/2;
	this.RightHip.DesiredAngle = 3.14/2;
	this.LeftHip.DesiredAngle = -3.14/2;
end