--[[
	Returns a table that chat reads and if a player is in it they are muted.
]]
local MuteSystem = {}
local TextChatService = game:GetService("TextChatService")

local mutedUsers = {}

function MuteSystem.muteUser(userId: number)
	mutedUsers[userId] = true;
	
	--for _, v in pairs(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"):GetDescendants()) do
	--	if v:IsA("TextSource") then
	--		if v.UserId == userId then
	--			v.CanSend = false
	--		end
	--	end
	--end
end

function MuteSystem.unmuteUser(userId: number)
	if userId then
		mutedUsers[userId] = nil;
	end
	
	--for _, v in pairs(TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"):GetDescendants()) do
	--	if v:IsA("TextSource") then
	--		if v.UserId == userId then
	--			v.CanSend = true
	--		end
	--	end
	--end
end

function MuteSystem.isUserMuted(userId: number)
	return mutedUsers[userId];
end

return MuteSystem