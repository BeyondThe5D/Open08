local module = {}

--Init
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrentCamera = workspace.CurrentCamera

function module:OldifyExplosion(Explosion : Explosion): ()
	if Explosion.Visible then
		Explosion.Visible = false

		local explosionVisual: SphereHandleAdornment = Instance.new("SphereHandleAdornment")
		explosionVisual.Color3 = Color3.fromRGB(255, 0, 0)
		explosionVisual.Radius = Explosion.BlastRadius * 0.75
		explosionVisual.CFrame = CFrame.new(Explosion.Position)
		explosionVisual.Adornee = workspace.Terrain
		explosionVisual.Parent = CurrentCamera
		
		explosionVisual.Visible = true
		Debris:AddItem(explosionVisual, Explosion.BlastRadius * 0.032)
	end
end

return module
