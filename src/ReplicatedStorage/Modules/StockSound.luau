--!strict
local SoundService: SoundService = game:GetService("SoundService")

local StockSound = {}
StockSound.__index = StockSound

function StockSound:PlaySound(stockSound: string, object: BasePart): ()
	local Sound: Instance? = SoundService:FindFirstChild(stockSound)
	
	if Sound and Sound:IsA("Sound") then
		local newSound: Sound = Sound:Clone()
		newSound.PlayOnRemove = true
		newSound.Parent = object or workspace -- If we have an object parameter we can parent the sound to the part for 3D sound, otherwise it's 2D or "global".
		
		newSound:Destroy()
	end
end

function StockSound:PlaySoundLocal(stockSound: string): ()
	local Sound: Instance? = SoundService:FindFirstChild(stockSound)
	
	if Sound then
		SoundService:PlayLocalSound(Sound)
	end
end

return StockSound
