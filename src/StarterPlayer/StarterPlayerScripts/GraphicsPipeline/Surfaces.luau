-- GAMES UNITE
local module = {}

local SurfaceTextures = {
	[Enum.SurfaceType.Studs] = "rbxassetid://1068388907",
	[Enum.SurfaceType.Inlet] = "rbxassetid://1068388840",
	[Enum.SurfaceType.Weld] = "rbxassetid://3447813050",
	[Enum.SurfaceType.Glue] = "rbxassetid://3527578761",
}

local CylinderSides = {
	Enum.NormalId.Left,
	Enum.NormalId.Right
}

local SurfaceNormals = {
	["TopSurface"] = Enum.NormalId.Top,
	["BottomSurface"] = Enum.NormalId.Bottom,
	["BackSurface"] = Enum.NormalId.Back,
	["FrontSurface"] = Enum.NormalId.Front,
	["RightSurface"] = Enum.NormalId.Right,
	["LeftSurface"] = Enum.NormalId.Left
}

local BlacklistedNormals = {
	[Enum.MeshType.Head] = {
		[Enum.NormalId.Top] = true,
		[Enum.NormalId.Bottom] = true,
		[Enum.NormalId.Back] = true,
		[Enum.NormalId.Front] = true,
		[Enum.NormalId.Right] = true,
		[Enum.NormalId.Left] = true
	},
	
	[Enum.MeshType.Wedge] = {
		[Enum.NormalId.Top] = true
	},
	
	[Enum.MeshType.FileMesh] = {
		[Enum.NormalId.Top] = true,
		[Enum.NormalId.Bottom] = true,
		[Enum.NormalId.Back] = true,
		[Enum.NormalId.Front] = true,
		[Enum.NormalId.Right] = true,
		[Enum.NormalId.Left] = true
	}
}

local function GetOffsets(BasePart : BasePart)
	return{
		["TopSurface"] = CFrame.Angles(math.rad(-90), 0, 0) * CFrame.new(0, 0, BasePart.Size.Y / 2),
		["BottomSurface"] = CFrame.Angles(math.rad(-90), 0, 0) * CFrame.new(0, 0, -BasePart.Size.Y / 2),
		["LeftSurface"] = CFrame.Angles(0, math.rad(90), 0) * CFrame.new(0, 0, -BasePart.Size.X / 2),
		["RightSurface"] = CFrame.Angles(0, math.rad(90), 0) * CFrame.new(0, 0, BasePart.Size.X / 2),
		["FrontSurface"] = CFrame.Angles(0, 0, 0) * CFrame.new(0, 0, -BasePart.Size.Z / 2),
		["BackSurface"] = CFrame.Angles(0, 0, 0) * CFrame.new(0, 0, BasePart.Size.Z / 2),	
	}
end

local function GrabTextures(BasePart : BasePart)
	local ReturnedData = {}
	
	for _, v in pairs(BasePart:GetChildren()) do
		if v:GetAttribute("FWMTexture") then
			table.insert(ReturnedData, v)
		end
	end
	
	return ReturnedData
end

local function GetValidSpecialMesh(BasePart: BasePart): SpecialMesh?
	if BasePart:FindFirstChildOfClass("SpecialMesh") then
		for _, v in pairs(BasePart:GetChildren()) do
			if v:IsA("SpecialMesh") and not v:GetAttribute("FWMTexture") then
				return v
			end
		end
	end
	
	return nil
end

local function ApplyPlus(BasePart: BasePart)
	local NewMesh = Instance.new("SpecialMesh")
	NewMesh.Name = "CylinderMesh"
	NewMesh.MeshType = Enum.MeshType.Cylinder
	NewMesh:SetAttribute("FWMTexture", true)
	NewMesh.Parent = BasePart
	
	for _, v in pairs(CylinderSides) do
		local PlusSide = Instance.new("SurfaceGui")
		PlusSide.LightInfluence = 1
		PlusSide.PixelsPerStud = 100
		PlusSide.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		PlusSide.Face = v
		PlusSide.Parent = BasePart
		local H = Instance.new("Frame")
		H.BackgroundColor3 = Color3.fromRGB(175, 175, 175)
		H.BorderSizePixel = 0
		H.Position = UDim2.new(0.1, 0, 0.5, -10)
		H.Size = UDim2.new(0.8, 0, 0, 20)
		H.Parent = PlusSide
		local V = Instance.new("Frame")
		V.BackgroundColor3 = Color3.fromRGB(175, 175, 175)
		V.BorderSizePixel = 0
		V.Position = UDim2.new(0.5, -10, 0.1, 0)
		V.Size = UDim2.new(0, 20, 0.8, 0)
		V.Parent = PlusSide
	end
end

local function ShineBasedOffMesh(BasePart : BasePart, Mesh : SpecialMesh?): ()
	if Mesh and Mesh.TextureId ~= "" then
		BasePart.MaterialVariant = ""
		BasePart.Material = Enum.Material.Brick
	else
		BasePart.Material = Enum.Material.SmoothPlastic
		BasePart.MaterialVariant = (BasePart.Reflectance < 0.01 and "Shiny") or ""
	end
end

local function HandleSurfacesFromMesh(BasePart : BasePart, HasMesh : SpecialMesh): ()
	local Type = HasMesh.MeshType
	local MeshTexture = HasMesh.TextureId
	local GetTextures = GrabTextures(BasePart)
	
	ShineBasedOffMesh(BasePart, HasMesh)
	
	if BlacklistedNormals[Type] then
		for _, v in pairs(GetTextures) do
			if v:IsA("Texture") then
				local GetSurface = string.gsub(v.Name, "LegacyTextureVisual_", "")
				v.Texture = SurfaceTextures[BasePart[GetSurface]] or ""
				
				if BlacklistedNormals[Type][v.Face] and v.Texture ~= "" then
					v.Texture = ""
				end
			end
		end
	end
end

local function DrawSurfaces(BasePart : BasePart, HasMesh : SpecialMesh?): ()
	local AdornmentsOffsets = GetOffsets(BasePart)
	local GetTextures = GrabTextures(BasePart)
	
	local FocusedMesh = HasMesh
	local MeshConnection = nil
	
	local ShapeUpdating = false
	
	local Connections = {}
	
	if BasePart:IsA("Part") and BasePart:GetAttribute("Cylinder") == true then
		ApplyPlus(BasePart)
	end
	
	for Surface, Normal in pairs(SurfaceNormals) do
		local SurfaceType = BasePart[Surface]
		local SurfaceUpdating = false
		
		local Texture = Instance.new("Texture")
		Texture.Name = "LegacyTextureVisual_"..Surface
		Texture.Texture = SurfaceTextures[SurfaceType] or ""
		Texture.StudsPerTileU = 2
		Texture.StudsPerTileV = 4
		Texture.Transparency = BasePart.Transparency + .2
		Texture.LocalTransparencyModifier = BasePart.LocalTransparencyModifier
		Texture.Face = Normal
		Texture.ZIndex = -1
		Texture:SetAttribute("FWMTexture", true)
		Texture.Parent = BasePart
		
		local MotorHinge = Instance.new("CylinderHandleAdornment")
		MotorHinge.CFrame = AdornmentsOffsets[Surface]
		MotorHinge.Name = "LegacyTextureVisual_"..Surface
		MotorHinge.Height = 1.01
		MotorHinge.Radius = 0.21
		MotorHinge.Color3 = Color3.fromRGB(255, 255, 0)
		MotorHinge.AlwaysOnTop = true
		MotorHinge.Visible = (SurfaceType == Enum.SurfaceType.Motor)
		MotorHinge.Adornee = BasePart
		MotorHinge:SetAttribute("FWMTexture", true)
		MotorHinge.Parent = BasePart

		local MotorHingeBack = Instance.new("CylinderHandleAdornment")
		MotorHingeBack.CFrame = AdornmentsOffsets[Surface]
		MotorHingeBack.Name = MotorHinge.Name.."_Background"
		MotorHingeBack.Height = 0.251
		MotorHingeBack.Radius = 0.41
		MotorHingeBack.Color3 = Color3.fromRGB(70, 70, 70)
		MotorHingeBack.AlwaysOnTop = true
		MotorHingeBack.Visible = MotorHinge.Visible
		MotorHingeBack.Adornee = BasePart
		MotorHingeBack.Parent = MotorHinge
		
		local Hinge = Instance.new("CylinderHandleAdornment")
		Hinge.CFrame = AdornmentsOffsets[Surface]
		Hinge.Name = "LegacyTextureVisual_"..Surface
		Hinge.Height = 1.01
		Hinge.Radius = 0.21
		Hinge.Color3 = Color3.fromRGB(255, 255, 0)
		Hinge.AlwaysOnTop = true
		Hinge.Visible = (SurfaceType == Enum.SurfaceType.Hinge)
		Hinge.Adornee = BasePart
		Hinge:SetAttribute("FWMTexture", true)
		Hinge.Parent = BasePart
		
		table.insert(Connections, BasePart:GetPropertyChangedSignal(Surface):Connect(function()
			Texture.Texture = SurfaceTextures[BasePart[Surface]] or ""
			
			Hinge.Visible = BasePart[Surface] == Enum.SurfaceType.Hinge
			MotorHinge.Visible = BasePart[Surface] == Enum.SurfaceType.Motor
			MotorHingeBack.Visible = MotorHinge.Visible
			
			if FocusedMesh then
				HandleSurfacesFromMesh(BasePart, FocusedMesh)
			end
		end))
	end
	
	table.insert(Connections, BasePart:GetPropertyChangedSignal("Reflectance"):Connect(function()
		ShineBasedOffMesh(BasePart, FocusedMesh)
	end))
	
	table.insert(Connections, BasePart:GetPropertyChangedSignal("Size"):Connect(function()
		local GetTextures = GrabTextures(BasePart)
		local GetOffsets = GetOffsets(BasePart)

		for _, v in pairs(GetTextures) do
			if v:IsA("CylinderHandleAdornment") then
				local SurfaceType = string.gsub(v.Name, "LegacyTextureVisual_", "")

				if GetOffsets[SurfaceType] then
					v.CFrame = GetOffsets[SurfaceType]

					local GetBackground = v:FindFirstChild(v.Name.."_Background")

					if not GetBackground then
						continue
					end

					GetBackground.CFrame = v.CFrame
				end
			end
		end
	end))
	
	table.insert(Connections, BasePart:GetPropertyChangedSignal("Transparency"):Connect(function()
		local GetTextures = GrabTextures(BasePart)
		
		for _, v in pairs(GetTextures) do
			if v:IsA("Texture") then
				v.Transparency = BasePart.Transparency + .2
			end
		end
	end))
	
	table.insert(Connections, BasePart:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		local GetTextures = GrabTextures(BasePart)

		for _, v in pairs(GetTextures) do
			if v:IsA("Texture") then
				v.LocalTransparencyModifier = BasePart.LocalTransparencyModifier
			end
		end
	end))
	
	table.insert(Connections, BasePart.ChildAdded:Connect(function(child)
		if child:IsA("SpecialMesh") and not child:GetAttribute("FWMTexture") then
			if MeshConnection then
				MeshConnection:Disconnect()
			end
			
			FocusedMesh = child
			
			MeshConnection = FocusedMesh:GetPropertyChangedSignal("MeshType"):Connect(function()
				HandleSurfacesFromMesh(BasePart, FocusedMesh)
			end)
			
			HandleSurfacesFromMesh(BasePart, FocusedMesh)
		end
	end))
	
	table.insert(Connections, BasePart.ChildRemoved:Connect(function(child)
		if child:IsA("SpecialMesh") and not child:GetAttribute("FWMTexture") then
			if MeshConnection then
				MeshConnection:Disconnect()
			end
			
			local SecondChance = GetValidSpecialMesh(BasePart)
			
			if SecondChance then
				FocusedMesh = SecondChance
				
				MeshConnection = FocusedMesh:GetPropertyChangedSignal("MeshType"):Connect(function()
					HandleSurfacesFromMesh(BasePart, FocusedMesh)
				end)
				
				return
			end
			
			FocusedMesh = nil
			MeshConnection = nil
			
			ShineBasedOffMesh(BasePart, FocusedMesh)
		end
	end))
	
	table.insert(Connections, BasePart.AncestryChanged:Connect(function(child, parent)
		if not parent then
			for _, v in pairs(Connections) do
				v:Disconnect()
			end
			
			if MeshConnection then
				MeshConnection:Disconnect()
				MeshConnection = nil
			end
		end
	end))
	
	if FocusedMesh then
		MeshConnection = FocusedMesh:GetPropertyChangedSignal("MeshType"):Connect(function()
			HandleSurfacesFromMesh(BasePart, FocusedMesh)
		end)
		
		HandleSurfacesFromMesh(BasePart, FocusedMesh)
	end
end

local function ApplySurfaces(BasePart: BasePart): ()	
	local FocusedMesh = GetValidSpecialMesh(BasePart)
	DrawSurfaces(BasePart, FocusedMesh)
end

function module:ApplySurfaceTextures(BasePart: BasePart): ()	
	BasePart.Material = Enum.Material.SmoothPlastic
	BasePart.CastShadow = false
	
	-- OOPS LOLOOLOLO completely forgot to add an "else" statement to things like this
	if BasePart.Reflectance < 0.01 then
		BasePart.MaterialVariant = "Shiny"
	else
		BasePart.MaterialVariant = ""
	end
	
	-- a small price to pay for salvation...
	local GetExisting = GrabTextures(BasePart)
	
	for _, v in pairs(GetExisting) do
		v:Destroy()
	end
	
	ApplySurfaces(BasePart)
end

return module