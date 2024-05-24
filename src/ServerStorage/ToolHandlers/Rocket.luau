local module = {}
module.__index = module

function module:Init()
	local NewTool = {}
	setmetatable(NewTool, module)
end

function module:ApplySettings(SettingsTable)
	self.Settings = SettingsTable
end

return module
