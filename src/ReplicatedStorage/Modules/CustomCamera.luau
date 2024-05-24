local CurrentCamera = workspace.CurrentCamera;
local Camera = {};
Camera.__index = Camera;

Camera.viewportScale = Vector2.zero;
Camera.viewportOffset = Vector2.zero;
Camera.billboards = {};

function Camera:AddBillboard(x)
	table.insert(self.billboards, x);
end

function Camera:ViewportPointToWorld(x, y)
	x += self.viewportOffset.X;
	
	local vps = CurrentCamera.ViewportSize;
	local depth = 0.1;

	local sx, sy = x/vps.X, y/vps.Y;
	local r = vps.X/vps.Y;
	local h = depth*math.tan(math.rad(CurrentCamera.FieldOfView*0.5));
	local w = r*h;

	local corner = Vector3.new(-w, h, -depth);
	local lp = corner + Vector3.new(2*sx*w, -2*sy*h, 0);

	local cframe = CurrentCamera.CFrame*CFrame.new(
		0,0,0,
		1,0,0,
		0,1,0,
		-self.viewportScale.X,0,1
	);

	local p = cframe*lp; -- MATRIX?? PLEASE
	local direction = (p - cframe.Position).unit;

	return Ray.new(cframe.Position+direction*depth, direction);
end

function Camera:WorldToScreenPoint(p)
	local lp = CurrentCamera.CFrame*CFrame.new(
		0,0,0,
		1,0,0,
		0,1,0,
		-self.viewportScale.X,0,1
	)*p;

	local vps = CurrentCamera.ViewportSize;
	local r = vps.X/vps.Y;

	local h = -math.min(lp.z,-0.1)*r;
	local w = r*h;
	local corner = Vector3.new(-w, h, lp.z);
	local relative = lp - corner;

	local sx = relative.X / (w*2);
	local sy = -relative.Y / (h*2);
	return Vector3.new(sx*vps.X, sy*vps.Y, -lp.Z);
end

return Camera;