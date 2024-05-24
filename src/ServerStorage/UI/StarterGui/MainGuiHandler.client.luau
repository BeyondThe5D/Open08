--[[
	FWM Official, 2022
	
	The main gui handler for FWM, does not reset
]]

local Chat: Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService: RunService = game:GetService("RunService")
local ScriptContext: ScriptContext = game:GetService("ScriptContext")
local StarterGui = game:GetService("StarterGui")
local TeleportService: TeleportService = game:GetService("TeleportService")
local TextChatService: TextChatService = game:GetService("TextChatService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local Teams: Teams = game:GetService("Teams")
local HttpService: HttpService = game:GetService("HttpService")

local DraggableObject = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DraggableObject"))
local StockSound = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("StockSound"))
local SuperSafeChat = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SuperSafeChat"))

local DecodedSuperSafeChat = HttpService:JSONDecode(SuperSafeChat)
local FullDecoded = DecodedSuperSafeChat["roblox"]["utterance"]
local MainGui = script.Parent
local GameSettings = UserSettings().GameSettings
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Solo = ReplicatedStorage:WaitForChild("Solo")

local HintFolder = ReplicatedStorage:WaitForChild("HintFolder")

local chats = {}
local chatTasks = {}

local registeredVisualInstances = {}

local playerlistdata: any = {
	players = {},
	teams = {},
}

local teamCount = 0

local canShowTeams = false
local safeChatOpened = false
local clickedExit = false

local lb_big = UDim2.new(0.33, 0, 0.018, 0)
local lb_small = UDim2.new(0.162, 0, 0.018, 0)

local NAME_COLORS: {Color3} = {
	--BrickColor.new("Crimson"), --r
	--BrickColor.new("Deep blue"), --g
	--BrickColor.new("Earth green"), --b
	--BrickColor.new("Bright violet"),
	--BrickColor.new("Bright orange"),
	--BrickColor.new("Bright yellow"),
	--BrickColor.new("Light reddish violet"),
	--BrickColor.new("Brick yellow"),
	Color3.fromRGB(173, 35, 35),
	Color3.fromRGB(42, 75, 215),
	Color3.fromRGB(29, 105, 20),
	Color3.fromRGB(129, 38, 192),
	Color3.fromRGB(255, 146, 51),
	Color3.fromRGB(255, 238, 51),
	Color3.fromRGB(255, 205, 243),
	Color3.fromRGB(233, 222, 187),
}

local whitelistedStringsTalk: any = {
	["[ERROR!]"] = {
		Username = {
			TextColor3 = Color3.fromRGB(255, 0, 0),
			TextStrokeTransparency = 0,
		},
		
		Text = {
			TextColor3 = Color3.fromRGB(255, 0, 0),
		}
	},
}

local function GetNameValue(pName: string): number
	local value = 0
	for index = 1, #pName do
		local cValue = string.byte(string.sub(pName, index, index))
		local reverseIndex = #pName - index + 1
		if #pName%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
		end
		value = value + cValue
	end
	return value
end

local color_offset = 0

local function ComputeNameColor(pName: string): Color3
	return NAME_COLORS[((GetNameValue(pName) + color_offset) % #NAME_COLORS) + 1]
end

task.wait(1)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCore("ChatActive", false)
UserInputService.MouseIconEnabled = false

--Functions:
local function ObjectAdded(obj): ()
	if (obj:IsA("Message") or obj:IsA("Hint")) and not registeredVisualInstances[obj] then
		registeredVisualInstances[obj] = true
		
		local connections = {}
		local parentChanging = false
		local objectClass = obj.ClassName -- :IsA doesn't work but this does??
		
		local grabbedInstanceGui = Templates.GuiInstances["FWM_"..tostring(objectClass).."_Instance"]:Clone()
		grabbedInstanceGui.Name = "LEGACY_INSTANCE"
		grabbedInstanceGui.Text = obj.Text
		grabbedInstanceGui.Parent = MainGui
		
		if objectClass == "Message" then
			grabbedInstanceGui.Visible = #obj.Text > 0
			obj.Text = ""
			
			if obj.Parent == LocalPlayer then
				grabbedInstanceGui.Position = UDim2.new(0, 30, 0, 30)
				grabbedInstanceGui.Size = UDim2.new(0.3, 0, 0.25, 0)
			end
		elseif objectClass == "Hint" then
			task.defer(function()
				obj.Parent = HintFolder
			end)
			
			if not MainGui.ChatBar.Visible then
				grabbedInstanceGui.AnchorPoint = Vector2.new(1, 0)
			else
				grabbedInstanceGui.AnchorPoint = Vector2.new(1, 1)
			end
		end
		
		table.insert(connections, obj:GetPropertyChangedSignal("Text"):Connect(function()
			if objectClass == "Message" then
				if obj.Text ~= "" then
					grabbedInstanceGui.Text = obj.Text
					grabbedInstanceGui.Visible = true
					obj.Text = ""
				end
			elseif objectClass == "Hint" then
				grabbedInstanceGui.Text = obj.Text
			end
		end))
		
		table.insert(connections, MainGui.ChatBar:GetPropertyChangedSignal("Visible"):Connect(function()
			if objectClass == "Hint" then
				if not MainGui.ChatBar.Visible then
					grabbedInstanceGui.AnchorPoint = Vector2.new(1, 0)
				else
					grabbedInstanceGui.AnchorPoint = Vector2.new(1, 1)
				end
			end
		end))
		
		table.insert(connections, obj.AncestryChanged:Connect(function(child, parent)
			local canDestroy = false
			
			if objectClass == "Message" then
				if obj:IsDescendantOf(workspace) then
					grabbedInstanceGui.Position = UDim2.new(0, 0, 0, 0)
					grabbedInstanceGui.Size = UDim2.new(1, 0, 1, 0)
				elseif obj.Parent == LocalPlayer then
					grabbedInstanceGui.Position = UDim2.new(0, 30, 0, 30)
					grabbedInstanceGui.Size = UDim2.new(0.3, 0, 0.25, 0)
				else
					canDestroy = true
				end
			elseif objectClass == "Hint" then
				if obj:IsDescendantOf(workspace) then
					if parentChanging then
						return
					end
					
					parentChanging = true
					
					task.defer(function()
						obj.Parent = HintFolder
					end)
					
					parentChanging = false
				elseif obj.Parent ~= HintFolder then
					canDestroy = true
				end
			end
			
			if canDestroy then
				for i, v in pairs(connections) do
					v:Disconnect()
				end

				grabbedInstanceGui:Destroy()
				registeredVisualInstances[obj] = nil
			end
		end))
	end
end

local function FullscreenMain(): ()
	local Topbar = MainGui:WaitForChild("Topbar")
	if GameSettings:InFullScreen() then
		Topbar.Fullscreen.ButtonText.Text = "x Fullscreen"
	else
		Topbar.Fullscreen.ButtonText.Text = "Fullscreen"
	end
end

local function getTeamCount(Team: Instance, StatName: string): number
	if Team:IsA("Team") then
		local Count = 0
		
		for i, v in pairs(Team:GetPlayers()) do
			local hasData = playerlistdata.players[v]
			
			if hasData then
				local statFocusing = hasData.statFocusing
				
				if statFocusing then
					local findValue = statFocusing:FindFirstChild(StatName)
					
					if findValue then
						Count += findValue.Value
					end
				end
			end
		end
		
		return Count
	end
	
	return 0
end

local function CreateLeaderstat()
	local Leaderstat = Instance.new("TextLabel")
	Leaderstat.BackgroundTransparency = 1
	Leaderstat.Size = UDim2.new(1, 0, 1, 0)
	Leaderstat.ZIndex = 9
	Leaderstat.Font = Enum.Font.GothamBold
	Leaderstat.Text = "???"
	Leaderstat.TextColor3 = Color3.fromRGB(242, 243, 243)
	Leaderstat.TextScaled = true
	Leaderstat.TextXAlignment = Enum.TextXAlignment.Left
	Leaderstat.TextYAlignment = Enum.TextYAlignment.Top
	
	return Leaderstat
end

local function refreshTeamStats(Team: Instance): ()
	if Team:IsA("Team") then
		local teamData = playerlistdata.teams[Team]
		local localData = playerlistdata.players[LocalPlayer]
	
		if teamData and localData then
			local isUI = localData.statsUI
			
			local statLabelConnections = localData.statLabelConnections
			local statFocusing = localData.statFocusing
			
			if statFocusing then
				local statAmount = #localData.statFocusing:GetChildren()

				if isUI then
					local isColor3 = Team:GetAttribute("Color3") ~= nil
					local TeamColor = isColor3 and Team:GetAttribute("Color3") or Team.TeamColor.Color
					
					for StatName, StatLabel in pairs(isUI) do
						local getTeamUI = teamData.teamStats[StatName]

						if not getTeamUI then
							local newStat = CreateLeaderstat()
							newStat.Name = StatName
							newStat.Text = getTeamCount(Team, StatName)
							newStat.TextColor3 = TeamColor
							newStat.TextStrokeTransparency = 0
							newStat.LayoutOrder = StatLabel.LayoutOrder
							newStat.Parent = teamData.teamFrames.mainFrame.TeamPoints

							teamData.teamStats[StatName] = newStat
						else
							getTeamUI.Text = getTeamCount(Team, StatName)
						end
					end

					for i, v in pairs(teamData.teamFrames.mainFrame.TeamPoints:GetChildren()) do
						if v:IsA("TextLabel") then
							if not localData.statsUI[v.Name] then
								v:Destroy()
							end
						end
					end
				end

				local getUIGrid = teamData.teamFrames.mainFrame.TeamPoints:FindFirstChildOfClass("UIGridLayout")		
				getUIGrid.CellSize = UDim2.new(1 / statAmount, 0, 1, 0)
			end
		end
	end
end

local function onTeamUpdate(Team: Instance): ()
	if Team:IsA("Team") and playerlistdata.teams[Team] then
		local teamData = playerlistdata.teams[Team]
		local mainFrame = teamData.teamFrames.mainFrame
		local isColor3 = Team:GetAttribute("Color3") ~= nil
		local TeamColor = isColor3 and Team:GetAttribute("Color3") or Team.TeamColor.Color
		
		--local TeamColor = Team.TeamColor.Color

		mainFrame.Name = "Team_"..Team.Name
		mainFrame.TeamNameLabel.Text = Team.Name
		mainFrame.TeamNameLabel.TextColor3 = TeamColor
		mainFrame.TeamBar.BorderColor3 = TeamColor

		for i, v in pairs(teamData.teamStats) do
			teamData.teamStats[i].TextColor3 = TeamColor
		end

		for i, v in pairs(Team:GetPlayers()) do
			local getData = playerlistdata.players[v]

			if getData then
				local playerFrame = getData.playerFrame
				
				local isColor3 = Team:GetAttribute("Color3") ~= nil
				local TeamColor = isColor3 and Team:GetAttribute("Color3") or Team.TeamColor.Color
				--local TeamColor = Team.TeamColor.Color

				playerFrame.NameLabel.TextColor3 = TeamColor

				for i, v in pairs(getData.statsUI) do
					getData.statsUI[i].TextColor3 = TeamColor
				end
			end
		end
	end
end

local function CreateTeamSplit(yScale : number)
	local TeamSplit = Instance.new("Frame")
	TeamSplit.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
	TeamSplit.BackgroundTransparency = 0.6
	TeamSplit.BorderSizePixel = 0
	TeamSplit.Position = UDim2.new(0, 0, 1, 0)
	TeamSplit.Size = UDim2.new(1, 0, yScale, 0)
	TeamSplit.ZIndex = 10
	
	return TeamSplit
end

local function CreateTeam()
	local Team = Instance.new("Frame")
	Team.Name = "Team"
	Team.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
	Team.BackgroundTransparency = 0.6
	Team.BorderSizePixel = 0
	Team.Position = UDim2.new(1.195, -277, 0.5, 10)
	Team.Size = UDim2.new(1, 0, 1, 0)
	Team.ZIndex = 9
	local TeamBar = Instance.new("Frame")
	TeamBar.Name = "TeamBar"
	TeamBar.AnchorPoint = Vector2.new(0.5, 0)
	TeamBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TeamBar.Position = UDim2.new(0.5, 0, 1, -1)
	TeamBar.Size = UDim2.new(0.985, 0, 0, 0)
	TeamBar.ZIndex = 10
	TeamBar.Parent = Team
	local TeamPoints = Instance.new("Frame")
	TeamPoints.Name = "TeamPoints"
	TeamPoints.AnchorPoint = Vector2.new(1, 0)
	TeamPoints.BackgroundTransparency = 1
	TeamPoints.Position = UDim2.new(1, 0, 0, 0)
	TeamPoints.Size = UDim2.new(0.5, 0, 1, 0)
	TeamPoints.Parent = Team
	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	UIGridLayout.CellSize = UDim2.new(1, 0, 1, 0)
	UIGridLayout.FillDirection = Enum.FillDirection.Vertical
	UIGridLayout.FillDirectionMaxCells = 9999
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIGridLayout.Parent = TeamPoints
	local TeamNameLabel = Instance.new("TextLabel")
	TeamNameLabel.Name = "TeamNameLabel"
	TeamNameLabel.BackgroundTransparency = 1
	TeamNameLabel.Size = UDim2.new(1, 0, 1, 0)
	TeamNameLabel.ZIndex = 9
	TeamNameLabel.Font = Enum.Font.GothamBold
	TeamNameLabel.Text = "Team"
	TeamNameLabel.TextColor3 = Color3.fromRGB(255, 255, 25)
	TeamNameLabel.TextScaled = true
	TeamNameLabel.TextStrokeTransparency = 0
	TeamNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	TeamNameLabel.TextYAlignment = Enum.TextYAlignment.Top
	TeamNameLabel.Parent = Team
	
	return Team
end

local function TeamAdded(Team: Instance): ()
	if Team:IsA("Team") and not playerlistdata.teams[Team] and canShowTeams then
		playerlistdata.teams[Team] = {
			teamFrames = {
				splitFrames = {
					topFrame = nil,
					bottomFrame = nil
				},
				mainFrame = nil,
			},

			teamStats = {},
			teamConnections = {},
			teamPriority = 0
		}

		teamCount += 1

		local teamData = playerlistdata.teams[Team]
		teamData.teamPriority = teamCount
		teamData.teamFrames.mainFrame = CreateTeam()
		teamData.teamFrames.splitFrames.topFrame = CreateTeamSplit(0.4)
		teamData.teamFrames.splitFrames.bottomFrame = CreateTeamSplit(0.8)

		local mainFrame = teamData.teamFrames.mainFrame
		local splitBottom = teamData.teamFrames.splitFrames.bottomFrame
		local splitTop = teamData.teamFrames.splitFrames.topFrame
		
		local isColor3 = Team:GetAttribute("Color3") ~= nil
		local TeamColor = isColor3 and Team:GetAttribute("Color3") or Team.TeamColor.Color
		--local TeamColor = Team.TeamColor.Color

		mainFrame.Name = "Team_"..Team.Name
		mainFrame.TeamNameLabel.Text = Team.Name
		mainFrame.TeamNameLabel.TextColor3 = TeamColor
		mainFrame.TeamBar.BorderColor3 = TeamColor
		mainFrame.LayoutOrder = teamData.teamPriority * 100

		splitBottom.LayoutOrder = mainFrame.LayoutOrder + 2
		splitTop.LayoutOrder = mainFrame.LayoutOrder + 1

		mainFrame.Parent = MainGui.Leaderboard
		splitBottom.Parent = MainGui.Leaderboard
		splitTop.Parent = MainGui.Leaderboard

		MainGui.Leaderboard.TeamSplit_VeryBottom.Visible = true

		table.insert(teamData.teamConnections, Team:GetPropertyChangedSignal("TeamColor"):Connect(function()
			onTeamUpdate(Team)
		end))

		table.insert(teamData.teamConnections, Team:GetPropertyChangedSignal("Name"):Connect(function()
			onTeamUpdate(Team)
		end))

		updatePlayerList()
	end
end

local function TeamRemoving(Team: Instance): ()
	if Team:IsA("Team") and playerlistdata.teams[Team] and teamCount > 0 then
		--teamCount -= 1

		local teamData = playerlistdata.teams[Team]

		for i, v in pairs(teamData.teamConnections) do
			v:Disconnect()
		end
		teamData.teamConnections = {}

		teamData.teamFrames.mainFrame:Destroy()

		for i, v in pairs(teamData.teamFrames.splitFrames) do
			teamData.teamFrames.splitFrames[i]:Destroy()
			teamData.teamFrames.splitFrames[i] = nil
		end
		teamData.teamFrames.splitFrames = {}

		for i, v in pairs(teamData.teamStats) do
			teamData.teamStats[i]:Destroy()
			teamData.teamStats[i] = nil
		end
		teamData.teamStats = {}

		playerlistdata.teams[Team] = nil

		updatePlayerList()
	end
end

local function fixStatsLayout(statName: string, newOrder: number): ()
	local localData = playerlistdata.players[LocalPlayer]
	
	if localData then
		for i, v in pairs(Players:GetPlayers()) do
			local playerData = playerlistdata.players[v]

			if playerData then
				local playerFrame = playerData.playerFrame
				local findStat = playerFrame.Leaderstats:FindFirstChild(statName)
					
				if findStat then
					findStat.LayoutOrder = newOrder
				end
			end
		end
	end
end

-- TODO: separate for less usage
local function updateBoard(): ()
	local localData = playerlistdata.players[LocalPlayer]

	if localData then
		local isFocusing = localData.statFocusing
		local trueStatAmount = localData.statAmount
		local statAmount = 1

		if isFocusing then
			statAmount = #isFocusing:GetChildren()

			MainGui.Leaderboard.TopBar.Player.Text = "Players"
			canShowTeams = true

			if MainGui.Leaderboard.Size ~= lb_big then
				MainGui.Leaderboard.Size = lb_big
			end

			if #Teams:GetTeams() > 0 then
				MainGui.Leaderboard.TopBar.Player.Text = "Team"
				MainGui.Leaderboard.TopSplit.Visible = false
				MainGui.Leaderboard.TeamSplit_VeryBottom.Visible = true
			else
				MainGui.Leaderboard.TopSplit.Visible = true
				MainGui.Leaderboard.TeamSplit_VeryBottom.Visible = false
			end
		else
			MainGui.Leaderboard.TopBar.Player.Text = "Player List"
			canShowTeams = false

			if MainGui.Leaderboard.Size ~= lb_small then
				MainGui.Leaderboard.Size = lb_small
			end

			MainGui.Leaderboard.TopSplit.Visible = true
			MainGui.Leaderboard.TeamSplit_VeryBottom.Visible = false
		end

		-- update top bar
		local getStatUI = localData.statsUI

		for StatObject, StatLabel in pairs(localData.statsUI) do
			local getLocal = localData.statsUI[StatObject]
			local findStat = MainGui.Leaderboard.TopBar.Leaderstats:FindFirstChild(StatObject)

			if not findStat then
				localData.statAmount += 1
				
				local newStat = CreateLeaderstat()
				newStat.Name = StatObject
				newStat.Text = StatObject
				newStat.LayoutOrder = localData.statAmount
				newStat.Parent = MainGui.Leaderboard.TopBar.Leaderstats
				
				fixStatsLayout(StatObject, localData.statAmount)
			end
		end

		for i, v in pairs(MainGui.Leaderboard.TopBar.Leaderstats:GetChildren()) do
			if v:IsA("TextLabel") then
				if not localData.statsUI[v.Name] then
					localData.statAmount -= 1				
					v:Destroy()
				end
			end
		end

		local getUIGrid = MainGui.Leaderboard.TopBar.Leaderstats:FindFirstChildOfClass("UIGridLayout")		
		getUIGrid.CellSize = UDim2.new(1 / statAmount, 0, 1, 0)
	end

	for i, v in pairs(Players:GetPlayers()) do
		onTeamChange(v)
	end

	if canShowTeams then	
		for i, v in ipairs(Teams:GetTeams()) do
			TeamAdded(v)
			refreshTeamStats(v)
		end
	else		
		for i, v in ipairs(Teams:GetTeams()) do
			if v:IsA("Team") then
				TeamRemoving(v)

				for i2, v2 in pairs(v:GetPlayers()) do
					onTeamChange(v2)
				end
			end
		end
	end
end

local function globalTeamRemoving(Team: Instance): ()
	TeamRemoving(Team)
end

local function globalTeamAdded(Team: Instance): ()
	TeamAdded(Team)
end

function updatePlayerList()
	updateBoard()
end

local function onStatRemoved(Stat: Instance, statName: string?, Player: Instance): ()
	if Stat:IsA("IntValue") then
		local grabbedPlayer = Player

		if grabbedPlayer and grabbedPlayer:IsA("Player") and playerlistdata.players[grabbedPlayer] then
			local data = playerlistdata.players[grabbedPlayer]

			local statFocusing = data.statFocusing
			local statAmount = 1
			
			local trueStatAmount = data.statAmount
			
			if statFocusing then
				statAmount = #data.statFocusing:GetChildren()
			end

			local dataFrame = data.playerFrame
			
			local grabbedName = statName or Stat.Name

			if data.statsUI[grabbedName] then
				local getStatUI = data.statsUI[grabbedName]	
				getStatUI:Destroy()

				local getUIGrid = dataFrame.Leaderstats:FindFirstChildOfClass("UIGridLayout")		
				getUIGrid.CellSize = UDim2.new(1 / statAmount, 0, 1, 0)

				local objectConnections = data.statLabelConnections[grabbedName]

				for i, v in pairs(objectConnections) do
					v:Disconnect()
				end
				data.statLabelConnections[grabbedName] = nil
				data.statsUI[grabbedName] = nil
				
				--data.statAmount -= 1
			end

			updatePlayerList()
		end
	end
end

local function onStatAdded(Stat: Instance): ()
	if Stat:IsA("IntValue") and Stat.Parent then
		local grabbedPlayer = Stat.Parent.Parent
		
		if grabbedPlayer and grabbedPlayer:IsA("Player") and playerlistdata.players[grabbedPlayer] then
			local data = playerlistdata.players[grabbedPlayer]
			local statLabelConnections = data.statLabelConnections
			local statFocusing = data.statFocusing
			local statAmount = #statFocusing:GetChildren()
			local dataFrame = data.playerFrame
			
			statLabelConnections[Stat.Name] = {}
			
			local focusedStatLabelConnection = statLabelConnections[Stat.Name]
			
			if not data.statsUI[Stat.Name] then
				local newStat = CreateLeaderstat()
				newStat.Name = Stat.Name
				newStat.Text = tostring(Stat.Value)
				newStat.LayoutOrder = statAmount
				
				if (not grabbedPlayer.Neutral) and grabbedPlayer.Team and playerlistdata.teams[grabbedPlayer.Team] then
					newStat.TextColor3 = grabbedPlayer.Team.TeamColor.Color
				end
				
				local currentName = Stat.Name
				
				table.insert(focusedStatLabelConnection, Stat:GetPropertyChangedSignal("Value"):Connect(function()
					newStat.Text = tostring(Stat.Value)
					
					if canShowTeams and playerlistdata.teams[grabbedPlayer.Team] and grabbedPlayer.Team then
						refreshTeamStats(grabbedPlayer.Team)
					end
				end))
				
				-- TODO: make this NOT use onStatRemoved
				--table.insert(focusedStatLabelConnection, Stat:GetPropertyChangedSignal("Name"):Connect(function()
				--	onStatRemoved(Stat, currentName, grabbedPlayer)
				--	onStatAdded(Stat)
				--end))
				
				newStat.Parent = dataFrame.Leaderstats
				
				local getUIGrid = dataFrame.Leaderstats:FindFirstChildOfClass("UIGridLayout")		
				getUIGrid.CellSize = UDim2.new(1 / statAmount, 0, 1, 0)
				
				data.statsUI[Stat.Name] = newStat
			end
			
			updatePlayerList()
		end
	end
end

local function HandleLeaderstats(Stat: Instance): ()
	if Stat:IsA("IntValue") and Stat.Name == "leaderstats" and Stat.Parent then
		local grabbedPlayer = Stat.Parent
		
		if grabbedPlayer and grabbedPlayer:IsA("Player") and playerlistdata.players[grabbedPlayer] then
			local playerData = playerlistdata.players[grabbedPlayer]
			playerData.statFocusing = Stat

			local statFocusing = playerData.statFocusing
			local statConnections = playerData.statConnections

			for i, v in ipairs(statFocusing:GetChildren()) do
				onStatAdded(v)
			end

			table.insert(statConnections, statFocusing.ChildAdded:Connect(onStatAdded))
			table.insert(statConnections, statFocusing.ChildRemoved:Connect(function(stat)
				onStatRemoved(stat, stat.Name, grabbedPlayer)
			end))

			updatePlayerList()
		end
	end
end

local function HandleLeaderstatsRemoval(Stat: Instance, Player: Instance): ()
	if Stat:IsA("IntValue") and Stat.Name == "leaderstats" then
		local grabbedPlayer = Player
		
		if grabbedPlayer and grabbedPlayer:IsA("Player") and playerlistdata.players[grabbedPlayer] then
			local playerData = playerlistdata.players[grabbedPlayer]
			local statFocusing = playerData.statFocusing
			
			if statFocusing == Stat then
				playerData.statFocusing = nil
				
				for i, v in pairs(playerData.statConnections) do
					v:Disconnect()
				end
				playerData.statConnections = {}
				
				for i, v in pairs(playerData.statsUI) do
					playerData.statsUI[i]:Destroy()
					playerData.statsUI[i] = nil
				end
				playerData.statsUI = {}
				
				for i, v in pairs(Stat:GetChildren()) do
					onStatRemoved(v, Stat.Name, grabbedPlayer)
				end
			end
			
			updatePlayerList()
		end
	end
end

local function neutralizePlayer(Player: Instance): ()
	if Player:IsA("Player") and playerlistdata.players[Player] then
		local playerData = playerlistdata.players[Player]
		
		if (#Teams:GetTeams() > 0) and canShowTeams then
			playerData.playerFrame.LayoutOrder = 0
			playerData.playerFrame.Visible = false
			
			for i, v in pairs(Teams:GetTeams()) do
				refreshTeamStats(v)
			end
		else
			playerData.playerFrame.LayoutOrder = 0
			playerData.playerFrame.NameLabel.TextColor3 = ComputeNameColor(playerData.playerFrame.NameLabel.Text)	
			playerData.playerFrame.Visible = true
			
			for i, v in pairs(playerData.statsUI) do
				playerData.statsUI[i].TextColor3 = Color3.fromRGB(242, 243, 243)
			end
		end
	end
end

local function changeTeam(Player: Instance): ()
	if Player:IsA("Player") then
		local getData = playerlistdata.players[Player]
		
		if getData and Player.Team then
			local acceptableTeam = playerlistdata.teams[Player.Team]
			
			if not acceptableTeam then
				neutralizePlayer(Player)
			else
				local playerFrame = getData.playerFrame
				
				local isColor3 = Player.Team:GetAttribute("Color3") ~= nil
				local TeamColor = isColor3 and Player.Team:GetAttribute("Color3") or Player.Team.TeamColor.Color
				--local TeamColor = Player.Team.TeamColor.Color

				playerFrame.NameLabel.TextColor3 = TeamColor

				for i, v in pairs(getData.statsUI) do
					getData.statsUI[i].TextColor3 = TeamColor
				end
				
				if not playerFrame.Visible then
					playerFrame.Visible = true
				end

				if playerFrame.LayoutOrder ~= acceptableTeam.teamFrames.mainFrame.LayoutOrder + 1 then
					playerFrame.LayoutOrder = acceptableTeam.teamFrames.mainFrame.LayoutOrder + 1
				end
			end
		end
		
		for i, v in pairs(Teams:GetTeams()) do
			refreshTeamStats(v)
		end
	end
end

function onTeamChange(Player: Instance): ()
	if Player:IsA("Player") and playerlistdata.players[Player] then
		if (playerlistdata.teams[Player.Team] and not Player.Neutral) then
			changeTeam(Player)
		else
			neutralizePlayer(Player)
		end
	end
end

local function CreatePlayer()
	local Player = Instance.new("Frame")
	Player.Name = "Player"
	Player.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
	Player.BackgroundTransparency = 0.6
	Player.BorderSizePixel = 0
	Player.Position = UDim2.new(1.195, -277, 0.5, 10)
	Player.Size = UDim2.new(1, 0, 1, 0)
	Player.ZIndex = 9
	
	local Leaderstats = Instance.new("Frame")
	Leaderstats.Name = "Leaderstats"
	Leaderstats.BackgroundTransparency = 1
	Leaderstats.Position = UDim2.new(1, 0, 0, 0)
	Leaderstats.Size = UDim2.new(0.5, 0, 1, 0)
	Leaderstats.Parent = Player
	local UIGridLayout = Instance.new("UIGridLayout")
	UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	UIGridLayout.CellSize = UDim2.new(1, 0, 1, 0)
	UIGridLayout.FillDirection = Enum.FillDirection.Vertical
	UIGridLayout.FillDirectionMaxCells = 9999
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIGridLayout.Parent = Leaderstats
	
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "NameLabel"
	NameLabel.BackgroundTransparency = 1
	NameLabel.Size = UDim2.new(1, 0, 1, 0)
	NameLabel.ZIndex = 9
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Text = "Player"
	NameLabel.TextColor3 = Color3.fromRGB(27, 42, 53)
	NameLabel.TextScaled = true
	NameLabel.TextStrokeColor3 = Color3.fromRGB(27, 42, 53)
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.TextYAlignment = Enum.TextYAlignment.Top
	NameLabel.Parent = Player
	
	return Player
end

local function PlayerAdded(Player: Instance): ()
	if Player:IsA("Player") and not playerlistdata.players[Player] then
		playerlistdata.players[Player] = {
			playerFrame = nil,
			statFocusing = nil,
			statConnections = {},
			statLabelConnections = {},
			playerConnections = {},
			statsUI = {},
			statAmount = 0
		}
		
		local playerInData = playerlistdata.players[Player]
		local playerConnections = playerInData.playerConnections
		
		playerInData.playerFrame = CreatePlayer()
		
		local newPlayerFrame = playerInData.playerFrame
		newPlayerFrame.Name = Player.UserId
		
		if not Solo.Value then
			newPlayerFrame.NameLabel.Text = string.sub(Player.Name, 1, 16)
			newPlayerFrame.NameLabel.TextColor3 = ComputeNameColor(newPlayerFrame.NameLabel.Text)	
		else
			newPlayerFrame.NameLabel.Text = "Player"
			newPlayerFrame.NameLabel.TextColor3 = Color3.fromRGB(42, 75, 215)
		end
		
		newPlayerFrame.Visible = true
		newPlayerFrame.Parent = MainGui.Leaderboard
		
		neutralizePlayer(Player)
	
		local foundStats = Player:FindFirstChild("leaderstats")

		if foundStats then
			HandleLeaderstats(foundStats)
		end
		
		table.insert(playerConnections, Player.ChildAdded:Connect(HandleLeaderstats))
		table.insert(playerConnections, Player.ChildRemoved:Connect(function(child)
			HandleLeaderstatsRemoval(child, Player)
		end))
		
		table.insert(playerConnections, Player:GetPropertyChangedSignal("Neutral"):Connect(function()
			onTeamChange(Player)
		end))

		table.insert(playerConnections, Player:GetPropertyChangedSignal("Team"):Connect(function()
			onTeamChange(Player)
		end))

		onTeamChange(Player)
	end
end

local function PlayerRemoving(Player: Instance): ()
	if Player:IsA("Player") then
		local getData = playerlistdata.players[Player]
		
		if getData then			
			for i, v in pairs(getData.statLabelConnections) do
				for i2, v2 in pairs(getData.statLabelConnections[i]) do
					v2:Disconnect()
				end
				
				getData.statLabelConnections[i] = nil
			end
			table.clear(getData.statLabelConnections)
			
			for i, v in pairs(getData.playerConnections) do
				v:Disconnect()
			end
			table.clear(getData.playerConnections)
			
			getData.statFocusing = nil
			
			for i, v in pairs(getData.statsUI) do
				getData.statsUI[i]:Destroy()
				getData.statsUI[i] = nil
			end
			getData.statsUI = {}
			getData.playerFrame:Destroy()
			
			playerlistdata.players[Player] = nil
		end
		
		updatePlayerList()
	end
end

local function CameraButtonMain(): ()
	StockSound:PlaySoundLocal("Step")
end

local function DisplayChatMessage(Chatter: any, Message, gotFiltered: boolean?): ()
	local ChatterType = typeof(Chatter)
	local IsWhitelisted = whitelistedStringsTalk[Chatter]

	local PlayerObject = ((ChatterType == "Instance") and Chatter:IsA("Player")) and Chatter
	local PlayerName
	
	if PlayerObject then
		PlayerName = PlayerObject.Name
	else
		PlayerName = tostring(Chatter)
	end
	
	if PlayerObject or IsWhitelisted then
		local ChatTemplate = Instance.new("Frame")
		ChatTemplate.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
		ChatTemplate.BackgroundTransparency = 0.6
		ChatTemplate.BorderSizePixel = 0
		ChatTemplate.Size = UDim2.new(1, 0, 0, 16)
		local MessageId = Instance.new("StringValue")
		MessageId.Name = "MessageId"
		MessageId.Parent = ChatTemplate
		local Username = Instance.new("TextLabel")
		Username.Name = "Username"
		Username.BackgroundTransparency = 1
		Username.Size = UDim2.new(0, 57, 1, 0)
		Username.Selectable = true -- might be enabled by accident?
		Username.Font = Enum.Font.GothamBold
		Username.Text = "Player;"
		Username.TextColor3 = Color3.fromRGB(0, 0, 0)
		Username.TextSize = 14
		Username.TextXAlignment = Enum.TextXAlignment.Left
		Username.Parent = ChatTemplate
		local MessageLabel = Instance.new("TextLabel")
		MessageLabel.Name = "Message"
		MessageLabel.BackgroundTransparency = 1
		MessageLabel.Position = UDim2.new(1, 10, 0, 0)
		MessageLabel.Size = UDim2.new(1, 0, 1, 0)
		MessageLabel.Font = Enum.Font.GothamBold
		MessageLabel.Text = "message"
		MessageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		MessageLabel.TextSize = 14
		MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
		MessageLabel.Parent = Username

		table.insert(chats, ChatTemplate)

		if #chats >= 7 then
			local firstChat = chats[1]

			task.cancel(chatTasks[firstChat])
			chatTasks[firstChat] = nil

			firstChat:Destroy()
			table.remove(chats, 1)
		end

		ChatTemplate.Username.Text = PlayerName.."; "
		ChatTemplate.Username.TextColor3 = ComputeNameColor(PlayerName)
		
		if PlayerObject and PlayerObject.Team and (not PlayerObject.Neutral) then
			local TeamOfPlayer = PlayerObject.Team
			
			local isColor3 = TeamOfPlayer:GetAttribute("Color3") ~= nil
			local TeamColor = isColor3 and TeamOfPlayer:GetAttribute("Color3") or TeamOfPlayer.TeamColor.Color
			
			ChatTemplate.Username.TextColor3 = TeamColor
		end
		
		-- Custom chats, refer to the "whiteListedStringsTalk" table for documentation
		if IsWhitelisted then
			local hasUserChange = whitelistedStringsTalk[Chatter].Username
			local hasTextChange = whitelistedStringsTalk[Chatter].Text

			if hasUserChange then
				for changing, value in pairs(hasUserChange) do
					ChatTemplate.Username[changing] = value
				end
			end

			if hasTextChange then
				for changing, value in pairs(hasTextChange) do
					ChatTemplate.Username.Message[changing] = value
				end
			end
		end

		ChatTemplate.Username.Message.Text = Message
		ChatTemplate.Username.Message.TextColor3 = gotFiltered and Color3.fromRGB(255, 0, 0) or ChatTemplate.Username.Message.TextColor3

		ChatTemplate.Parent = MainGui.ChatWindow

		ChatTemplate.Username.Size = UDim2.new(0,ChatTemplate.Username.TextBounds.X,1,0)
		ChatTemplate.Username.Message.Size = UDim2.new(0,ChatTemplate.Username.Message.TextBounds.X + 12,1,0)
		ChatTemplate.Size = UDim2.new(0,ChatTemplate.Username.TextBounds.X + ChatTemplate.Username.Message.TextBounds.X + 12,0,16)

		chatTasks[ChatTemplate] = task.delay(64, function()
			local isStillInChat = table.find(chats, ChatTemplate)

			if isStillInChat then
				ChatTemplate:Destroy()
				chatTasks[ChatTemplate] = nil

				table.remove(chats, isStillInChat)
			end
		end)
	end
end

local function destroyFocusedSuperSafeChats(focusedElement): ()
	local buttonStyle = focusedElement:FindFirstChild("ButtonStyle")
	
	if buttonStyle then
		buttonStyle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	
	focusedElement.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	
	for i, v in pairs(focusedElement:GetDescendants()) do
		if v.Name == "List" then
			v.Visible = false
		elseif v.Name == "ButtonStyle" and v.BackgroundColor3 ~= Color3.fromRGB(255, 255, 255) then
			v.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end

local function makeSuperSafeChatElementsVisible(optionElement: TextButton): ()
	local buttonStyle = optionElement:FindFirstChild("ButtonStyle")

	if buttonStyle and buttonStyle:IsA("Frame") then
		buttonStyle.BackgroundColor3 = Color3.fromRGB(178, 178, 178)
	end
	
	optionElement.BackgroundColor3 = Color3.fromRGB(178, 178, 178)
	
	local grabbedList: Instance? = optionElement:FindFirstChild("List")

	if grabbedList and grabbedList:IsA("Frame") then
		grabbedList.Visible = true
	end
end

local function superSafeChatBubbleClicked(): ()
	if not safeChatOpened then
		safeChatOpened = true

		MainGui.SuperSafeChatBubble.Image = "rbxassetid://12483705914"
		MainGui.SuperSafeChatBubble.List.Visible = true
	else
		safeChatOpened = false

		MainGui.SuperSafeChatBubble.Image = "rbxassetid://12483706070"
		MainGui.SuperSafeChatBubble.List.Visible = false
	end
end

local function createSuperSafeChatButton(indexTable, buttonParent): TextButton
	local Option: TextButton = Instance.new("TextButton")
	Option.Name = "SafeChatOption"
	Option.BackgroundTransparency = 1
	Option.Position = UDim2.new(0, 0, 0.929, 0)
	Option.Size = UDim2.new(0, 138, 0, 25)
	Option.Font = Enum.Font.Cartoon
	Option.Text = ""
	Option.TextColor3 = Color3.fromRGB(0, 0, 0)
	Option.TextSize = 1
	Option.TextTransparency = 1
	local buttonStyle = Instance.new("Frame")
	buttonStyle.Name = "ButtonStyle"
	buttonStyle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	buttonStyle.BorderSizePixel = 0
	buttonStyle.Size = UDim2.new(1, 0, 0, 20)
	buttonStyle.Parent = Option
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Name = "Round"
	UIStroke.Thickness = 2
	UIStroke.Parent = buttonStyle
	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.Font = Enum.Font.Cartoon
	Label.TextColor3 = Color3.fromRGB(0, 0, 0)
	Label.TextSize = 12
	Label.Parent = buttonStyle
	
	if buttonStyle then
		local textLabel = buttonStyle:FindFirstChild("TextLabel")
		
		if textLabel and textLabel:IsA("TextLabel") then
			textLabel.Text = tostring(indexTable["#text"] or indexTable)
		end
	end
	
	Option.Parent = buttonParent:WaitForChild("List")

	return Option
end

local function onSuperSafeChatOptionClicked(button: TextButton): ()
	StockSound:PlaySoundLocal("Click")
	destroyFocusedSuperSafeChats(MainGui.SuperSafeChatBubble)
	superSafeChatBubbleClicked()

	local ChatMain = require(LocalPlayer.PlayerScripts:WaitForChild("ChatScript", nil):WaitForChild("ChatMain", nil))
	local ButtonStyle = button:FindFirstChild("ButtonStyle")

	if ButtonStyle then
		local TextLabel = ButtonStyle:FindFirstChild("TextLabel")

		if TextLabel and TextLabel:IsA("TextLabel") then
			ChatMain.MessagePosted:fire(TextLabel.Text)
		end
	end
end

local DefaultTextBoxText = MainGui.ChatBar.TextBox.Text

local function HandleInputBegan(input: InputObject, gameProcessedEvent: boolean): ()
	if input.KeyCode == Enum.KeyCode.Slash and UserInputService:GetFocusedTextBox() == nil then
		RunService.RenderStepped:Wait()
		MainGui.ChatBar.TextBox:CaptureFocus()
	elseif safeChatOpened and input.UserInputType ~= Enum.UserInputType.MouseMovement and not gameProcessedEvent then
		superSafeChatBubbleClicked()
		destroyFocusedSuperSafeChats(MainGui.SuperSafeChatBubble)
	end
end

local function OnChatBarFocused(): ()
	MainGui.ChatBar.TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
	MainGui.ChatBar.BackgroundColor3 = Color3.fromRGB(230, 230, 250)

	if MainGui.ChatBar.TextBox.Text == DefaultTextBoxText then
		MainGui.ChatBar.TextBox.Text = ""
	end
end

local function OnChatBarFocusLost(enterPressed): ()
	MainGui.ChatBar.TextBox.TextColor3 = Color3.fromRGB(255, 255, 200)
	MainGui.ChatBar.BackgroundColor3 = Color3.fromRGB(64, 64, 64)

	if enterPressed then
		if MainGui.ChatBar.TextBox.Text ~= "" then
			local ChatMain = require(LocalPlayer.PlayerScripts:WaitForChild("ChatScript", nil):WaitForChild("ChatMain", nil))

			ChatMain.MessagePosted:fire(MainGui.ChatBar.TextBox.Text)

			MainGui.ChatBar.TextBox:ReleaseFocus()
			MainGui.ChatBar.TextBox.Text = DefaultTextBoxText
		end
	end
end

local function OnExit(): ()
	if clickedExit then
		return
	end
	
	clickedExit = true
	
	local IsStudio = RunService:IsStudio()
	local MessageDecided = IsStudio and "Cannot Teleport in the Studio." or "Teleporting to the Menu. Please wait..."
	
	local ExitMessage = Instance.new("Message")
	ExitMessage.Name = "ExitMessage"
	ExitMessage.Text = MessageDecided
	ExitMessage.Parent = workspace
	
	if not IsStudio then
		TeleportService:Teleport(17588164210, Players.LocalPlayer, nil, nil)
	end
end

local function Errored(msg, trace, err)
	DisplayChatMessage("[ERROR!]", tostring(msg))
end

local function superSafeChatParser(list, rootButton: GuiButton)	
	local focusedElement: any = nil
	for i, v in pairs(list) do
		local Option = createSuperSafeChatButton(v, rootButton)
		
		Option.MouseEnter:Connect(function()
			if focusedElement then
				destroyFocusedSuperSafeChats(focusedElement)
			end
			
			focusedElement = Option
			makeSuperSafeChatElementsVisible(focusedElement)
		end)
		
		Option.MouseButton1Click:Connect(function()
			onSuperSafeChatOptionClicked(Option)
			focusedElement = nil
		end)
		
		if v["utterance"] ~= nil then
			local utteranceTable = v["utterance"]
			local utteranceType = typeof(utteranceTable)
			
			local NewList = Instance.new("Frame")
			NewList.Name = "List"
			NewList.BackgroundTransparency = 1
			NewList.Position = UDim2.new(1, 5, 0, 0)
			NewList.Size = UDim2.new(0, 100, 1, 0)
			NewList.Visible = false
			local UIListLayout = Instance.new("UIListLayout")
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			UIListLayout.Parent = NewList
			Instance.new("UIPadding", NewList)
			
			NewList.Parent = Option

			if utteranceType == "table" then
				superSafeChatParser(utteranceTable, Option)
				
				NewList:WaitForChild("UIPadding").PaddingBottom = UDim.new(0, 24)
			else
				local newButton = createSuperSafeChatButton(utteranceTable, Option)
				
				newButton.MouseButton1Click:Connect(function()
					onSuperSafeChatOptionClicked(newButton)
					focusedElement = nil
				end)
				
				newButton.MouseEnter:Connect(function()
					focusedElement = newButton
					makeSuperSafeChatElementsVisible(newButton)
				end)
			end
		end
	end
end

--Hookup:

UserInputService.InputBegan:Connect(HandleInputBegan)

MainGui.ChatBar.TextBox.Focused:Connect(OnChatBarFocused)
MainGui.ChatBar.TextBox.FocusLost:Connect(OnChatBarFocusLost)
ReplicatedStorage.Protocols.Chat.OnClientEvent:Connect(function(player, message, gotFiltered)
	local getType = typeof(player)
	local isWhitelistedString = whitelistedStringsTalk[player]
	
	if player and (getType == "string" and isWhitelistedString) or (getType == "Instance" and player:IsA("Player")) then
		DisplayChatMessage(player, message, gotFiltered)
	end
end)

MainGui.Topbar.Exit.MouseButton1Click:Connect(OnExit)

for _, v in pairs(workspace:GetDescendants()) do
	ObjectAdded(v)
end

FullscreenMain()

workspace.DescendantAdded:Connect(ObjectAdded)
LocalPlayer.ChildAdded:Connect(ObjectAdded)
GameSettings.FullscreenChanged:Connect(FullscreenMain)

for _, v in pairs(Players:GetPlayers()) do
	PlayerAdded(v)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

for _, v in pairs(LocalPlayer:GetChildren()) do
	ObjectAdded(v)
end

for _, v in pairs(MainGui:WaitForChild("CameraControl"):WaitForChild("CameraButtons"):GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(CameraButtonMain)
	end
end

Teams.ChildAdded:Connect(TeamAdded)
Teams.ChildRemoved:Connect(TeamRemoving)

ScriptContext.Error:Connect(Errored)

superSafeChatParser(FullDecoded, MainGui.SuperSafeChatBubble)
MainGui.SuperSafeChatBubble.Visible = true
MainGui.SuperSafeChatBubble.MouseButton1Click:Connect(superSafeChatBubbleClicked)

MainGui.CameraControl.Position = UDim2.new(1, 5, 1, -15)
MainGui.CameraControl.ReportButton.Visible = true

-- disables camera buttons for mobile, since we kept getting complaints about that
if (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
	MainGui.CameraControl.Visible = false
end

-- disable chat if privacy settings say so
if Solo.Value == false and Chat:CanUserChatAsync(LocalPlayer.UserId) then
	return
else
	MainGui.ChatBar.Visible = false
	MainGui.ChatWindow.Visible = false
	MainGui.SuperSafeChatBubble.Visible = false
	MainGui.CameraControl.ReportButton.Visible = false
	MainGui.CameraControl.Position = UDim2.new(1, MainGui.CameraControl.Position.X.Offset, 1, 6)
end

-- make a house