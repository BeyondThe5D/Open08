local Replacements = {}

local Humanoid = require(script.Parent.Humanoid)

local BODY_PART_NAMES: {string} = {
	["Left Arm"] = true,
	["Left Leg"] = true,
	["Right Arm"] = true,
	["Right Leg"] = true,
	["Torso"] = true,
}

local SoundsToOld = {
	["rbxasset://sounds/uuhhh.wav"] = "rbxassetid://1033209269"
}

local DecalsToOld = {
	["rbxasset://textures/face.png"] = "rbxassetid://17594019045",
	["rbxasset://textures/spawnlocation.png"] = "rbxassetid://17594018006"
}

function Replacements:TintColor(Part : BasePart): ()
	Part.Color = BrickColor.new(Part.Color).Color

	local randomAmount: number = 6 / 255
	local random: Random = Random.new()
	local hue: number, saturation: number, value: number = Part.Color:ToHSV()

	Part.Color = Color3.fromHSV(hue, math.clamp(random:NextNumber(saturation - randomAmount * 1.0, saturation + randomAmount * 1.0), 0, 1), math.clamp(random:NextNumber(value - randomAmount * 0.5, value + randomAmount * 0.5), 0, 1))
end

function Replacements:Unbevel(Model : Model): ()
	for _, Object in pairs(Model:GetChildren()) do
		local BodyPart = BODY_PART_NAMES[Object.Name]
		
		if BodyPart then
			local BlockMesh = Instance.new("SpecialMesh")
			BlockMesh.MeshType = Enum.MeshType.Brick
			BlockMesh.Parent = Object
		end
	end
end

function Replacements:HeadHumanoidCheck(Part : BasePart): ()
	if Part.Name == "Head" and Part.Parent then
		local HasHumanoid = Part.Parent:FindFirstChildOfClass("Humanoid")
		local AlreadyApplied = Part:FindFirstChildOfClass("BillboardGui")
		
		if HasHumanoid and not AlreadyApplied then		
			Humanoid:ApplyHealthBar(HasHumanoid)
		end
	end
end

function Replacements:HeadMesh(Mesh: SpecialMesh): ()	
	local Part : Instance? = Mesh.Parent
	
	if Part and Part:IsA("BasePart") and Mesh.MeshType == Enum.MeshType.Head then
		Mesh.MeshId = "rbxassetid://7390281327"
		
		local OldMeshScale = Mesh.Scale

		if Part.Size.X > Part.Size.Z then
			Mesh.Scale = Vector3.new(Part.Size.Z * OldMeshScale.Z, Part.Size.Y * OldMeshScale.Y, Part.Size.Z * OldMeshScale.Z)
		else
			Mesh.Scale = Vector3.new(Part.Size.X * OldMeshScale.Z, Part.Size.Y * OldMeshScale.Y, Part.Size.X * OldMeshScale.Z)
		end
		
		local Conns = {} -- HANDLES STUFF, GOOD GOING KEY
		table.insert(Conns, Part:GetPropertyChangedSignal("Size"):Connect(function()			
			if Part.Size.X > Part.Size.Z then
				Mesh.Scale = Vector3.new(Part.Size.Z * OldMeshScale.Z, Part.Size.Y * OldMeshScale.Y, Part.Size.Z * OldMeshScale.Z)
			else
				Mesh.Scale = Vector3.new(Part.Size.X * OldMeshScale.Z, Part.Size.Y * OldMeshScale.Y, Part.Size.X * OldMeshScale.Z)
			end
			
			OldMeshScale = Mesh.Scale
		end))
		
		table.insert(Conns, Mesh:GetPropertyChangedSignal("MeshType"):Connect(function()
			if Mesh.MeshType ~= Enum.MeshType.Head and not (Mesh.MeshType == Enum.MeshType.FileMesh and Mesh.MeshId == "rbxassetid://7390281327") then
				for _, v in pairs(Conns) do
					v:Disconnect()
				end
			end
		end))
		
		table.insert(Conns, Part.AncestryChanged:Connect(function(Child, Parent)
			if not Parent then
				for _, v in pairs(Conns) do
					v:Disconnect()
				end
			end
		end))
	end
end

function Replacements:OldifySound(Sound: Sound): ()
	if (not SoundsToOld[Sound.SoundId]) then
		return
	end
	
	Sound.SoundId = SoundsToOld[Sound.SoundId]
end

function Replacements:OldifyTexture(Decal: Decal): ()
	local FindTexture = DecalsToOld[Decal.Texture:lower()]
	
	if FindTexture then
		Decal.Texture = FindTexture
	end
end

return Replacements