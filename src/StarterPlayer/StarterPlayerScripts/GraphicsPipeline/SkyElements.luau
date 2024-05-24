local module = {}

--Init:
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HeldSky = Instance.new("Sky")
HeldSky.Name = "PlainSky"
HeldSky.MoonAngularSize = 0
HeldSky.MoonTextureId = ""
HeldSky.SkyboxBk = "rbxasset://sky/null_plainsky512_bk.jpg"
HeldSky.SkyboxDn = "rbxasset://sky/null_plainsky512_dn.jpg"
HeldSky.SkyboxFt = "rbxasset://sky/null_plainsky512_ft.jpg"
HeldSky.SkyboxLf = "rbxasset://sky/null_plainsky512_lf.jpg"
HeldSky.SkyboxRt = "rbxasset://sky/null_plainsky512_rt.jpg"
HeldSky.SkyboxUp = "rbxasset://sky/null_plainsky512_up.jpg"
HeldSky.StarCount = 0
HeldSky.SunTextureId = "rbxassetid://6958593179"
HeldSky:SetAttribute("FWMTexture", true)

local sunRayRaycast = RaycastParams.new()
sunRayRaycast.FilterDescendantsInstances = {workspace.CurrentCamera}
sunRayRaycast.FilterType = Enum.RaycastFilterType.Blacklist -- 5/28/2023: bro I aint switching to Exclude

--moonHolder.CFrame = CFrame.new(sunPos)
--moonHolder.Position = (sunPos:Cross(moonPos).Unit * 2000) + (workspace.CurrentCamera.CFrame.Position)
--moonHolder.Position = Vector3.new(4748.924, 2565.836, 4768.066) + workspace.CurrentCamera.CFrame.Position

--Flare Config:
type LensFlareConfiguration = {
	scale: number,
	texture: string,
	transparency: number,
}

type Lense = {
	attachment0: Attachment?,
	attachment1: Attachment?,
	beam: Beam?,
	distance: number,
	color: Color3,
	radius: number,
}

local lensFlareNode: Part = Instance.new("Part")
lensFlareNode.Name = "LensFlareNode"
lensFlareNode.Anchored = true
lensFlareNode.CanCollide = false
lensFlareNode.CanQuery = false
lensFlareNode.CanTouch = false
lensFlareNode.Locked = true
lensFlareNode.Transparency = 1
lensFlareNode.Parent = workspace.CurrentCamera

local sunAdorn = Instance.new("Part")
sunAdorn.Transparency = 1
sunAdorn.Size = Vector3.new(0.1, 0.1, 0.1) -- ?
sunAdorn.CanCollide = false
sunAdorn.CanQuery = false -- ?
sunAdorn.CanTouch = false -- ?
sunAdorn.Anchored = true
local Attachment0 = Instance.new("Attachment")
Attachment0.Name = "Attachment0"
Attachment0.CFrame = CFrame.new(0, -0.5, 0.8)
Attachment0.Parent = sunAdorn
local Attachment1 = Instance.new("Attachment")
Attachment1.Name = "Attachment1"
Attachment1.CFrame = CFrame.new(0, 0.5, 0.8)
Attachment1.Parent = sunAdorn
local SunRayTexture = Instance.new("Beam")
SunRayTexture.Name = "SunRayTexture"
SunRayTexture.LightEmission = 1
SunRayTexture.Texture = "rbxasset://sky/sun-rays.jpg"
SunRayTexture.TextureSpeed = 0
SunRayTexture.Transparency = NumberSequence.new(0)
SunRayTexture.Attachment0 = Attachment0
SunRayTexture.Attachment1 = Attachment1
SunRayTexture.FaceCamera = true
SunRayTexture.Segments = 1
SunRayTexture.Parent = sunAdorn
local lastClockTime: number = nil

local lensFlareConfiguration: LensFlareConfiguration = {
	scale = 1 / 8;
	texture = "rbxasset://textures/whiteCircle.png";
	transparency = 0.9;
}

local defaultSkyValues = {
	MoonAngularSize = 0,
	MoonTextureId = "",
	StarCount = 0,
	SunAngularSize = 21,
	SunTextureId = "rbxassetid://6958593179",
	CelestialBodiesShown = true,
}

local LENSES: {Lense} = 
	{
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(200, 255, 200),
			distance = 0.000,
			radius = 1.00,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(  0, 255,   0),
			distance = 0.200,
			radius = 0.50,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(255,   0,   0),
			distance = 0.225,
			radius = 0.30,
		};
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(255, 170,   0),
			distance = 0.250,
			radius = 1.50,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(255, 170,   0),
			distance = 0.250,
			radius = 3.00,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(  0, 255,   0),
			distance = 0.300,
			radius = 0.50,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(  0, 255,   0),
			distance = 0.600,
			radius = 0.20,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(  0, 255,   0),
			distance = 0.650,
			radius = 0.40,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(255,   0,   0),
			distance = 0.780,
			radius = 0.20,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB(  0, 255,   0), 
			distance = 0.900,
			radius = 0.25,
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB( 63,  63,  63), 
			distance = 1.200,
			radius = 0.15, 
		},
		{
			attachment0 = nil,
			attachment1 = nil,
			beam = nil,
			color = Color3.fromRGB( 63,  63,  63), 
			distance = 1.500,
			radius = 0.15, 
		},
	}

--Flare Functions:
local function asVector2(vector3: Vector3, ...): (Vector2, any)
	-- Roblox likes to kill my OCD.
	return Vector2.new(vector3.X, vector3.Y), ...
end

--local function isSunOccluded(sunDir: Vector3): ()
--	local origin = workspace.CurrentCamera.CFrame.Position + (workspace.CurrentCamera.CFrame.LookVector * 2)
--	local ray = Ray.new(origin,origin + (sunDir * 10e6))
--	local ignore = {}
--	local occluded = false
	
--	if sunDir:Dot(workspace.CurrentCamera.CFrame.LookVector) > 0 then
--		while true do
--			local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray,ignore)
--			if hit then
--				local t = hit.Transparency + hit.LocalTransparencyModifier
--				if t <= 0 then
--					occluded = true
--					break
--				else
--					table.insert(ignore,hit)
--				end
--			else
--				break
--			end
--		end
--	end
	
--	return occluded
--end

-- replication of getDepthBufferValue from G3D's source code (specifically in Sky.cpp)
local function getDepthBufferValue()
	local sunDir = Lighting:GetSunDirection()
	local cameraObject = workspace.CurrentCamera
	local cameraCFrame = cameraObject.CFrame
	local visible = 0
	local rays = 0
	local cameraPosition = nil
	
	if sunDir:Dot(cameraCFrame.LookVector) > 0 then
		local realSize = cameraObject:WorldToViewportPoint(cameraCFrame.Position + sunDir)
		local vec, inView = asVector2(cameraObject:WorldToViewportPoint(sunDir * 10e6))
		
		if inView then
			cameraPosition = cameraObject:ViewportPointToRay(realSize.X, realSize.Y).Origin

			for dx = -1, 1 do
				for dy = -1, 1 do								
					local viewPort = cameraObject:ViewportPointToRay(
						math.round(realSize.X + dx * 15), 
						math.round(realSize.Y + dy * 15)
					)

					rays += 1
					local cast = workspace:Raycast(viewPort.Origin, viewPort.Direction * 5000, sunRayRaycast)

					if not cast then
						visible += 1
					end
				end
			end
		end
	end
	
	return (visible / rays), cameraPosition
end

local function createLenseBeam(lense: Lense, id: number): Beam
	local radius: number = lense.radius * lensFlareConfiguration.scale

	local attachment0: Attachment = Instance.new("Attachment")
	attachment0.Name = id .. "_A0"
	attachment0.Parent = lensFlareNode
	lense.attachment0 = attachment0

	local attachment1: Attachment = Instance.new("Attachment")
	attachment1.Name = id .. "_A1"
	attachment1.Parent = lensFlareNode
	lense.attachment1 = attachment1

	local beam: Beam = Instance.new("Beam")
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Color = ColorSequence.new(lense.color)
	beam.LightEmission = 1
	beam.Name = tostring(id)
	beam.Texture = lensFlareConfiguration.texture
	beam.TextureSpeed = 0
	beam.Width0 = radius
	beam.Width1 = radius
	beam.Parent = lensFlareNode

	lense.beam = beam

	return beam
end

local function updateLensFlare(): ()
	local vpSize: Vector2 = workspace.CurrentCamera.ViewportSize
	local moonDir: Vector3 = Lighting:GetMoonDirection()
	local sunDir: Vector3 = Lighting:GetSunDirection()
	local sunWrldSpace: Vector3 = sunDir * 10e6
	local sunScrnSpace: Vector2, inView: boolean = asVector2(workspace.CurrentCamera:WorldToViewportPoint(sunWrldSpace))
	local sunScrnSpaceInv: Vector2 = workspace.CurrentCamera.ViewportSize - sunScrnSpace
	local amount, position = getDepthBufferValue()
	local enabled = (amount > 0.01 and sunDir.Y > -.1)
	--local enabled = (position ~= nil)

	for i: number, lense: Lense in ipairs(LENSES) do
		local beam = lense.beam or createLenseBeam(lense, i)	
		
		local squareRoot = math.sqrt(math.max(0, sunDir.Y * 4))
		local transparencyEquation = 0.04 * squareRoot
		local finalTransparency = 1 - transparencyEquation
		
		beam.Transparency = NumberSequence.new(finalTransparency)
		beam.Enabled = enabled

		if enabled then
			local radius: number = lense.radius * lensFlareConfiguration.scale
			local lenseSP: Vector2 = sunScrnSpaceInv:Lerp(sunScrnSpace, lense.distance)
			local lenseWP: Vector3 = workspace.CurrentCamera:ViewportPointToRay(lenseSP.X, lenseSP.Y, 1).Origin
			local lenseCF: CFrame = CFrame.new(lenseWP, lenseWP - sunDir)

			if lense.attachment0 and lense.attachment1 then
				lense.attachment0.CFrame = lenseCF * CFrame.new(-radius / 2, 0, 0)
				lense.attachment1.CFrame = lenseCF * CFrame.new(radius / 2, 0, 0)
			end
		end
	end
end

local moonHolder = Instance.new("Part")
moonHolder.Transparency = 1
moonHolder.CanCollide = false
moonHolder.Anchored = true
moonHolder.CanTouch = false
moonHolder.CanQuery = false
moonHolder.Locked = true
moonHolder.Parent = workspace.CurrentCamera
moonHolder.Name = "FWM_LEGACY_MOON"

local moonTextureHolder: BillboardGui = Instance.new("BillboardGui")
moonTextureHolder.ClipsDescendants = false
moonTextureHolder.LightInfluence = 0
moonTextureHolder.Name = "Interface"
moonTextureHolder.Size = UDim2.new(0, 75, 0, 75)
moonTextureHolder.Parent = moonHolder

local moonTexture: ImageLabel = Instance.new("ImageLabel")
moonTexture.BackgroundTransparency = 1
moonTexture.Image = "rbxassetid://8753438296"
moonTexture.Name = "Texture"
moonTexture.Rotation = -65
moonTexture.Size = UDim2.new(1, 0, 1, 0)
moonTexture.ResampleMode = Enum.ResamplerMode.Pixelated
moonTexture.Parent = moonTextureHolder

local stars = {}
local nightLegacy = Instance.new("Part")
nightLegacy.Name = "FWM_LEGACY_NIGHT"
nightLegacy.Transparency = 1
nightLegacy.CanCollide = false
nightLegacy.Anchored = true
nightLegacy.CanTouch = false
nightLegacy.CanQuery = false
nightLegacy.Locked = true
nightLegacy.Parent = workspace.CurrentCamera
nightLegacy.Position = Vector3.zero

local function moonUpdate(): ()
	local currentCamera = workspace.CurrentCamera
	local cameraCFrame = currentCamera.CFrame
	
	local sunPos = Lighting:GetSunDirection()
	local moonPos = Lighting:GetMoonDirection()
	local crossEquation = moonPos:Cross(-sunPos)
	
	local moonActualPosition = moonPos:Cross(moonPos:Cross(Vector3.zAxis)).Unit
	local moonTransparency = math.clamp(moonActualPosition.Y * 4, 0, 1)
	
	moonHolder.CFrame = CFrame.new(crossEquation.Unit * 2500, sunPos) + cameraCFrame.Position + Vector3.new(0, 150, 4000).Unit * 2000
	moonTexture.ImageTransparency = moonTransparency
end

--local Ratio;
--local Size;
--local function can_see_target(lp)
--	local r = Size.X/Size.Y;
--	local h = -math.min(lp.z,0)*Ratio;
--	local w = r*h;
--	local corner = Vector3.new(-w, h, lp.z);
--	local relative = lp - corner;
--	local sx = relative.X / (w*2);
--	local sy = -relative.Y / (h*2);
--	return -lp.Z > 0 and sx >=0 and sx <= 1 and sy >=0 and sy <= 1;
--end

local CurrentCamera = workspace.CurrentCamera;

local function handleStars(): ()	
	local sunPos = Lighting:GetSunDirection()
	local moonPos = Lighting:GetMoonDirection()
	local currentClockTime = Lighting.ClockTime
	local starsClamp = math.clamp(sunPos.Y * 10, 0, 1)
	
	--Ratio = math.tan(math.rad(CurrentCamera.FieldOfView/2));
	--Size = CurrentCamera.ViewportSize;
	
	--if moonPos.Y < -0.3 then
	--	nightLegacy.Parent = nil
	--	return
	--end
	
	local cameraCFrame = CurrentCamera.CFrame;
	nightLegacy.CFrame = CFrame.new(cameraCFrame.Position) 
		* CFrame.lookAt(Vector3.zero, sunPos)
	
	if lastClockTime == currentClockTime then
		return
	end
	
	lastClockTime = currentClockTime
	
	--local invCameraMatrix = cameraCFrame.Rotation:inverse();
	--local matrix = invCameraMatrix * nightLegacy.CFrame.Rotation;
	for position, starframe in stars do
		starframe.StarFrame.BackgroundTransparency = starsClamp
	end
end

local function updateSunRay(): ()
	local sunDir = Lighting:GetSunDirection()
	local amount, position = getDepthBufferValue()
	local currentCamera = workspace.CurrentCamera
	
	if sunDir.X < 0 or sunDir.Y < -.1 or (not position) then
		sunAdorn.Parent = nil
		
		return
	end
	
	local occulusionAttenuation = 1 - ((2 * amount - 1) ^ 2)
	local equationForSun = occulusionAttenuation * 0.4 * math.clamp(1 - sunDir.Y * 2 / math.sqrt(2), 0, 1)
	local finalEquation = 1 - equationForSun

	sunAdorn.Parent = currentCamera
	sunAdorn.SunRayTexture.Transparency = NumberSequence.new(finalEquation)
	sunAdorn.CFrame = CFrame.new(position, currentCamera.CFrame.Position)
end

local function otherSkyBoxes(): boolean
	for i, v in pairs(Lighting:GetChildren()) do
		if v:IsA("Sky") and not v:GetAttribute("FWMTexture") then
			return true
		end
	end
	
	return false
end

local function getFWMSky(): ()
	local findName = Lighting:FindFirstChild("PlainSky")
	
	if not findName then
		return
	end
	
	for i, v in pairs(Lighting:GetChildren()) do
		local isFWMSky = v:GetAttribute("FWMTexture")
		
		if v:IsA("Sky") and isFWMSky then
			return v
		end
	end
end

local function initializeAlreadyExisting(alreadyExist: Sky): ()
	local isOfficialTexture = alreadyExist:GetAttribute("FWMTexture")
	
	if alreadyExist:IsA("Sky") and (not isOfficialTexture) and alreadyExist.StarCount > 0 then
		for propertys, values in defaultSkyValues do
			alreadyExist[propertys] = values
		end
	end
end

local function registerSkyBox(newSkybox: Sky)	
	if newSkybox:IsA("Sky") then
		local theresOthers = otherSkyBoxes()
		
		-- roblox added StarCount in like the 2010s and every skybox made before that had had their StarCount set to 3000
		if newSkybox.StarCount > 0 then
			for propertys, values in defaultSkyValues do
				newSkybox[propertys] = values
			end
		end
		
		if theresOthers then
			local grabbedSky = getFWMSky()

			if grabbedSky then
				task.defer(function()
					HeldSky.Parent = script
				end)
			end
		end
	end
end

local function unregisterSkyBox(removedSkybox: Sky)
	local isOfficialTexture = removedSkybox:GetAttribute("FWMTexture")
	
	if removedSkybox:IsA("Sky") and not isOfficialTexture then
		local findOthers = otherSkyBoxes()
		
		if findOthers or (not HeldSky) then
			return
		end
		
		task.defer(function()
			HeldSky.Parent = Lighting
		end)
	end
end

local function skyboxHandler(): ()
	local getSky = Lighting:FindFirstChildOfClass("Sky")
	
	if not getSky then
		HeldSky.Parent = Lighting
	end
	
	for i, v in pairs(Lighting:GetChildren()) do
		initializeAlreadyExisting(v)
	end

	Lighting.ChildAdded:Connect(registerSkyBox)
	Lighting.ChildRemoved:Connect(unregisterSkyBox)
end

function module:InitializeElements()
	skyboxHandler()
	
	RunService:BindToRenderStep("updateLensFlare", 201, updateLensFlare)
	RunService:BindToRenderStep("moonUpdate", 201, moonUpdate)
	
	RunService:BindToRenderStep("updateSunRay", 201, updateSunRay)
		
	for i = 1, 750 do
		local newStar = Instance.new("BillboardGui")
		newStar.Name = "FWM_STAR"
		newStar.ResetOnSpawn = false
		newStar.AutoLocalize = false -- ?
		local StarFrame = Instance.new("Frame")
		StarFrame.Name = "StarFrame"
		StarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		StarFrame.BorderSizePixel = 0
		StarFrame.Size = UDim2.new(1, 0, 1, 0)
		StarFrame.ZIndex = 0
		StarFrame.Parent = newStar

		local sizeAmt = math.random(1, 3)
		newStar.Size = UDim2.new(0, sizeAmt, 0, sizeAmt)
		newStar.StudsOffsetWorldSpace = Vector3.new(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000)).Unit * 5000
		newStar.Parent = nightLegacy
		newStar.Adornee = nightLegacy

		--stars[newStar.StudsOffset] = newStar.StarFrame;
		table.insert(stars, newStar)
	end

	RunService:BindToRenderStep("handleStars", 201, handleStars)
end

return module