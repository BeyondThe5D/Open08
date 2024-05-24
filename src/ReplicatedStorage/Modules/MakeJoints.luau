-- created by madgangz

local matrix_right = CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1);
local function make_att(part, where)
	local att = Instance.new("Attachment");
	att.CFrame = part.CFrame:inverse() * where * matrix_right;
	att.Parent = part;
	return att;
end

local function apply_constraint(part0, part1, where, axis)
	local constraint = Instance.new("HingeConstraint");
	constraint.Attachment0 = make_att(part0, where);
	constraint.Attachment1 = make_att(part1, where);
	constraint.Parent = part0;
	return constraint;
end

local directions = {
	[Vector3.xAxis] = "Right";
	[Vector3.yAxis] = "Top";
	[Vector3.zAxis] = "Front";
	[-Vector3.xAxis] = "Left";
	[-Vector3.yAxis] = "Bottom";
	[-Vector3.zAxis] = "Back";
};

local caster_region = 1;
local caster_point = 0;
local caster_modes = {
	[Enum.SurfaceType.Motor] = caster_point;
	[Enum.SurfaceType.Hinge] = caster_point;

	[Enum.SurfaceType.Studs] = caster_region;
	[Enum.SurfaceType.Inlet] = caster_region;
	[Enum.SurfaceType.Weld] = caster_region;	
};

local paramA = "%sParamA";
local function weld(part0, part1, cframe, dir, prop)
	local constraint = Instance.new("WeldConstraint");
	constraint.Part0 = part0;
	constraint.Part1 = part1;
	constraint.Parent = part0;
end

local whitelisted = {
	[Enum.SurfaceType.Motor] = function(part0, part1, cframe, dir, prop)
		local constraint = apply_constraint(part0, part1, cframe, dir);
		constraint.ActuatorType = Enum.ActuatorType.Motor;
		constraint.MotorMaxTorque = part0[paramA:format(prop)];
	end;

	[Enum.SurfaceType.Hinge] = function(part0, part1, cframe, dir, prop)
		local constraint = apply_constraint(part0, part1, cframe, dir);
		constraint.ActuatorType = Enum.ActuatorType.Servo;
		constraint.ServoMaxTorque = part0[paramA:format(prop)];
	end;

	[Enum.SurfaceType.Studs] = weld;
	[Enum.SurfaceType.Inlet] = weld;
	[Enum.SurfaceType.Weld] = weld;
};

local surface_type = "%sSurface";
local epsilon = 0.1;
return function(part)
	if(not part:IsA("BasePart"))then
		return;
	end

	local cframe = part.CFrame;
	local origin = cframe:inverse();
	local size = part.Size*0.5;

	local joints = {};
	for dir, prop in directions do
		local surface = part[surface_type:format(prop)];
		local actuator = whitelisted[surface];
		if(not actuator)then
			continue;
		end

		if(caster_modes[surface] == caster_region)then
			for _, hit in workspace:GetPartBoundsInBox(cframe*CFrame.new(size*dir + dir*0.25), size - dir*size:Dot(dir) + Vector3.one)do
				if(not hit.CanCollide or part==hit or joints[hit])then
					continue;
				end

				joints[hit] = true;
				actuator(part, hit, cframe*CFrame.new(size*dir), dir, prop);
			end
		else
			for _, hit in workspace:GetPartBoundsInRadius(cframe * (size * dir), 0.25) do
				if(not hit.CanCollide or part==hit or joints[hit])then
					continue;
				end

				joints[hit] = true;
				actuator(part, hit, cframe*CFrame.new(size*dir), dir, prop);
			end
		end
	end
end