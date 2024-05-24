--!strict
--[[
	Classic Roblox Clothes! 2022
	
	Handle chat messages serverside for text-filtering and broadcasting to players.
]]
local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TextService: TextService = game:GetService("TextService")
local ScriptContext: ScriptContext = game:GetService("ScriptContext")
local HttpService: HttpService = game:GetService("HttpService")

local SuperSafeChat = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SuperSafeChat"))
local DecodedSuperSafeChat = HttpService:JSONDecode(SuperSafeChat)
local FullDecoded = DecodedSuperSafeChat["roblox"]["utterance"]

local MuteSystem = require(script:WaitForChild("MuteSystem"))
local protocols = ReplicatedStorage:WaitForChild("Protocols")

local function findSSC(tabl)
	local candecode = tabl[1]
	local isValid = tonumber(candecode)
	local currentDecode = nil
	
	if isValid then
		currentDecode = FullDecoded[isValid + 1]

		if candecode and currentDecode then	
			for i, v in pairs(tabl) do
				if i == 1 then
					continue
				end

				local newValue = tonumber(v)
				
				if newValue then
					if not currentDecode then
						break
					end

					local trueValue = newValue + 1
					
					if currentDecode["utterance"] then
						local getType = typeof(currentDecode["utterance"])
						
						if getType == "table" then
							local grabbedDecode = currentDecode["utterance"][trueValue]
							
							if grabbedDecode then
								currentDecode = grabbedDecode
							else
								currentDecode = currentDecode[trueValue]
							end
						else
							currentDecode = (trueValue == 1 and currentDecode["utterance"]) or nil
						end
					end
				end
			end

			if currentDecode and currentDecode["#text"] then
				currentDecode = currentDecode["#text"]
			end
		end
	end

	return currentDecode or ""
end

Players.PlayerAdded:Connect(function(player: Player): ()
	player.Chatted:Connect(function(message: string, recipient: Player): ()
		if MuteSystem.isUserMuted(player.UserId) then
			return
		end
		
		local noWhiteSpace = string.gsub(message, "\n", " ")
		local textFilterResult: Instance = TextService:FilterStringAsync(noWhiteSpace, player.UserId, Enum.TextFilterContext.PublicChat)

		if textFilterResult:IsA("TextFilterResult") then
			for i: number, v: Player in ipairs(Players:GetPlayers()) do
				if Chat:CanUsersChatAsync(player.UserId, v.UserId) then

					local filteredMessage: string = textFilterResult:GetChatForUserAsync(v.UserId)
					local gotFiltered: boolean = message ~= filteredMessage
					
					local findSc = string.sub(filteredMessage, 1, 3)

					if findSc == "/sc" then
						local subbedsc = string.split(filteredMessage, " ")			
						table.remove(subbedsc, 1)

						filteredMessage = (#subbedsc >= 1 and findSSC(subbedsc)) or "ROOT"
					end
					
					if gotFiltered and player.UserId ~= v.UserId then
						continue
					end

					protocols.Chat:FireClient(v, player, filteredMessage, gotFiltered)
					
					if message:match("//") then -- anti-thomas technology
						player:Kick()
					end
					
				end
			end
		end
	end)
end)

ScriptContext.Error:Connect(function(message: string, stackTrace: string, script: Instance): ()	
	for i: number, v: Player in ipairs(Players:GetPlayers()) do
		--if Chat:CanUsersChatAsync(player.UserId, v.UserId) then
			--local filteredMessage: string = textFilterResult:GetChatForUserAsync(v.UserId)

			protocols.Chat:FireClient(v, "[ERROR!]", message)
		--end
	end
end)

-- april fools

--local aprilfoolsmessage = {
--	"YOU ARE BEING WATCHED",
--	"I AM COMING...",
--	"HACKING PLACE...",
--	"I have you PC NAME",
--	"consider yourself lucky...",
--	"JohnsPuzzleGame is a FRAUD",
--	"whoever made this you caused all this pain and agony",
--	"I'm watching...",
--	"HACKED BY MADGANGZ",
--	"PBB seems like a GREAT game to upload onto FWM!",
--	"SFOTH I release date: NEVER",
--	"TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO Do not touch the keyboard TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO TECHNO",
--	":baldi all",
--	"127.0.0.1"
--}

--while true do
--	local ran = math.random(1, 60)
--	local randommes = aprilfoolsmessage[math.random(1, #aprilfoolsmessage)]
--	task.wait(ran)
	
--	for i: number, v: Player in ipairs(Players:GetPlayers()) do
--		protocols.Chat:FireClient(v, "[MADGANGZ]", randommes)
--	end
--end