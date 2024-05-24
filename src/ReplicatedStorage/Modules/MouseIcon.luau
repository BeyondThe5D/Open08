--[[
	
	File Name: MouseIcon.lua
	Written by: Gamer (@Roblox_Gamer2030)
	Description: Mouse module for FWM, has a IconLibrary set up for it

]]--
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local MouseIcon = {}

-- Library of 2006 cursors set up
local ICONLIBRARY: {[string] : string} = {
	
	-- rbxasset://textures\\TEXTURE.png
	["rbxasset://textures\\ArrowCursor.png"] = "rbxassetid://7167309450",
	["rbxasset://textures\\ArrowFarCursor.png"] = "rbxassetid://7167309465",
	
	["rbxasset://textures\\GunCursor.png"] = "rbxassetid://6958990174",
	["rbxasset://textures\\GunWaitCursor.png"] = "rbxassetid://6958990714",
	
	["rbxasset://textures\\CloneCursor.png"] = "rbxassetid://7167495528",
	["rbxasset://textures\\CloneOverCursor.png"] = "rbxassetid://7167545116",	
	["rbxasset://textures\\DragCursor.png"] = "rbxassetid://7167515791",
	["rbxasset://textures\\GrabRotateCursor.png"] = "rbxassetid://7167495541",
	["rbxasset://textures\\HammerCursor.png"] = "rbxassetid://7167495543",
	["rbxasset://textures\\HammerOverCursor.png"] = "rbxassetid://7167495538",
	
	["rbxasset://textures\\FillCursor.png"] = "rbxassetid://9799205192",
	["rbxasset://textures\\DropperCursor.png"] = "rbxassetid://9799203397",
	
	["rbxasset://textures\\AnchorCursor.png"] = "rbxassetid://9802191685",
	["rbxasset://textures\\UnAnchorCursor.png"] = "rbxassetid://9802192705",
	
	
	-- rbxasset://textures//TEXTURE.png
	["rbxasset://textures//ArrowCursor.png"] = "rbxassetid://7167309450",
	["rbxasset://textures//ArrowFarCursor.png"] = "rbxassetid://7167309465",

	["rbxasset://textures//GunCursor.png"] = "rbxassetid://6958990174",
	["rbxasset://textures//GunWaitCursor.png"] = "rbxassetid://6958990714",

	["rbxasset://textures//CloneCursor.png"] = "rbxassetid://7167495528",
	["rbxasset://textures//CloneOverCursor.png"] = "rbxassetid://7167545116",	
	["rbxasset://textures//DragCursor.png"] = "rbxassetid://7167515791",
	["rbxasset://textures//GrabRotateCursor.png"] = "rbxassetid://7167495541",
	["rbxasset://textures//HammerCursor.png"] = "rbxassetid://7167495543",
	["rbxasset://textures//HammerOverCursor.png"] = "rbxassetid://7167495538",
	
	["rbxasset://textures//AnchorCursor.png"] = "rbxassetid://9802191685",
	["rbxasset://textures//UnAnchorCursor.png"] = "rbxassetid://9802192705"
	
}

function MouseIcon.Icon(icon)
	if player.PlayerGui:FindFirstChild("MainGui") ~= nil then
		player.PlayerGui.MainResetGui.Cursor.Image = ICONLIBRARY[icon] or icon
	end	
end

return MouseIcon
