local CurrentCamera = workspace.CurrentCamera;
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local CustomCamera = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CustomCamera"));
local RunService = game:GetService("RunService");

local UIPadding = script.Parent:WaitForChild("UIPadding");

local ViewportSize;
local function getPositionMatrix()
	local offset = -UIPadding.PaddingRight.Offset;
	local position = offset/ViewportSize;
	
	local r = ViewportSize.X/ViewportSize.Y;
	local h = math.tan(math.rad(CurrentCamera.FieldOfView)*0.5);
	local w = h*r;
	
	return -position.X*w, -offset;
end

RunService:BindToRenderStep("cameraOffsetMatrix", Enum.RenderPriority.Camera.Value+1, function()
	local vp = CurrentCamera.ViewportSize;
	ViewportSize = Vector2.new(vp.X, vp.Y);
	
	local x, px = getPositionMatrix();
	CustomCamera.viewportOffset = Vector2.new(px*0.5,0);
	CustomCamera.viewportScale = Vector2.new(x,0);
	
	local right = CurrentCamera.CFrame.RightVector;
	local skew = CFrame.new(
		0,0,0,
		1,0,0,
		0,1,0,
		x,0,1
	);

	CurrentCamera.CFrame *= skew;
	--for _, billboard in CustomCamera.billboards do
	--	if(not billboard.Parent)then
	--		continue;
	--	end

	--	local cframe = billboard.Parent.CFrame;
	--	local origin = cframe*-Vector3.yAxis + Vector3.yAxis*1.5;
	--	local screen = CustomCamera:WorldToScreenPoint(origin);
		
	--	local point = CustomCamera:ViewportToWorldPoint(screen.X, screen.Y);
	--	point = point.Origin + point.Direction*screen.Z;
		
	--	billboard.ExtentsOffsetWorldSpace = point - screen;
	--end

end)