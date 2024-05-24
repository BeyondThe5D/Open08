--[[

	FWM Official, 2022
	Modification of ROBLOX Battle's Explosion Module, for FWM

]]--

local module = {}
local Debris = game:GetService("Debris")

--local function HandleExplosion(Position)
--	local delta = p.Position - TimeBomb.Position

--	--Vector3 normal = 
--	--	(delta == Vector3::zero())
--	--	? Vector3::unitY()
--	--	: delta.direction();
--	local normal = (delta == Vector3.new(0,0,0))
--		and Vector3.new(0,1,0)
--		or  delta.unit

--	--float radius = p->getRadius();
--	local radius = p.Size.magnitude / 2				

--	--float surfaceArea = radius * radius;
--	local surfaceArea = radius * radius

--	--Vector3 impulse = normal * blastPressure * surfaceArea * (1.0f / 4560.0f); // normalizing factor
--	local impulse = normal * BLAST_PRESSURE * surfaceArea * (1.0 / 4560.0)

--	-- How much force to apply (for characters, ramp it down towards the edge)
--	local frac;
--	if isInCharacter then
--		frac = 1 - math.max(0, math.min(1, (r-2)/BLAST_RADIUS))
--	else
--		frac = 1
--	end					

--	--p->getBody()->accumulateLinearImpulse(impulse, p->getCoordinateFrame().translation);
--	local currentVelocity = p.Velocity
--	local deltaVelocity = impulse / p:GetMass() -- m * del-v = F * del-t = Impulse
--	local bodyV = Instance.new('BodyVelocity', p)
--	bodyV.velocity = currentVelocity + deltaVelocity
--	local forceNeeded = 196.2 * p:GetMass() -- F = ma
--	bodyV.maxForce = Vector3.new(forceNeeded, forceNeeded, forceNeeded) * 10 * frac
--	game.Debris:AddItem(bodyV, 0.2/FORCE_GRANULARITY)

--	--p->getBody()->accumulateRotationalImpulse(impulse * 0.5 * radius); // a somewhat arbitrary, but nice torque
--	local rotImpulse = impulse * 0.5 * radius
--	local currentRotVelocity = p.RotVelocity
--	local momentOfInertia = (2 * p:GetMass() * radius * radius / 5) -- moment of inertia = 2/5*m*r^2 (assuming roughly spherical)
--	local deltaRotVelocity = rotImpulse / momentOfInertia 
--	local rot = Instance.new('BodyAngularVelocity', p)
--	local torqueNeeded = 20 * momentOfInertia -- torque = r x F, want about alpha = 20 rad/s^2, alpha * P = torque
--	rot.maxTorque = Vector3.new(torqueNeeded, torqueNeeded, torqueNeeded) * 10 * frac
--	rot.angularvelocity = currentRotVelocity + deltaRotVelocity
--	game.Debris:AddItem(rot, 0.2/FORCE_GRANULARITY)
--end


--function module:CreateExplosion()
--	local New = Instance.new("Explosion")
--	New.BlastRadius = 6 -- Default Radius
	
--	New.Hit:Connect(function(PartTouched, Distance)		
--		local FakeBlastPressure = New.BlastPressure
--		New.BlastPressure = 0
--	end)
	
--	return New
--end

--return module