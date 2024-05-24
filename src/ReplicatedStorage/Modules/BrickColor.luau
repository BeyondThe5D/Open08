--[[

	Replica of ROBLOX's BrickColor library from 2006

]]--

local colorCodes: {number} = {1, 208, 194, 199, 26, 21, 24, 226, 23, 107, 102, 11, 45, 135, 106, 105, 141, 28, 37, 119, 29, 151, 38, 192, 104, 9, 101, 5, 153, 217, 18, 125}
local module = {}

function module.Random(): BrickColor
	return BrickColor.new(colorCodes[math.random(1, #colorCodes)])
end

function module.random(): BrickColor
	return BrickColor.new(colorCodes[math.random(1, #colorCodes)])
end

function module.Blue() : BrickColor
	return BrickColor.Blue()
end

function module.Yellow() : BrickColor
	return BrickColor.Yellow()
end

function module.Red() : BrickColor
	return BrickColor.Red()
end

function module.Gray() : BrickColor
	return BrickColor.Gray()
end

function module.Black() : BrickColor
	return BrickColor.Black()
end

function module.Green() : BrickColor
	return BrickColor.Green()
end

function module.White() : BrickColor
	return BrickColor.White()
end

function module.DarkGray() : BrickColor
	return BrickColor.DarkGray()
end

--TODO: Make it act like how March 2007 would handle RGB colors (finds nearest brickcolor in color palette)
function module.new(R, G, B) : BrickColor
	local brickColor = R or 0
	local validColorCode = table.find(colorCodes, brickColor)
	local validBrickColor = table.find(colorCodes, BrickColor.new(brickColor).Number)
	
	if (G == nil and B == nil) then
		if (validColorCode or validBrickColor) then
			return BrickColor.new(brickColor)
		end
	else
		return BrickColor.new(R, G, B)
	end
	
	return BrickColor.new("Medium stone grey")
end

return module
