local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomCamera = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CustomCamera"));
local CustomFont = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CustomFont"))
local IsSolo = ReplicatedStorage:WaitForChild("Solo")

local Humanoid = {}

function Humanoid:ApplyHealthBar(humanoid: Humanoid): ()
	local HumanoidParent: Instance? = humanoid.Parent

	if HumanoidParent then
		local CurrentHead: Instance? = HumanoidParent:FindFirstChild("Head")

		if CurrentHead and CurrentHead:IsA("Part") then		
			local Connections = {}

			-- If just somehow an extra one slipped through
			local GrabbedExtra = CurrentHead:FindFirstChildOfClass("BillboardGui")

			if GrabbedExtra then
				GrabbedExtra:Destroy()
			end

			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

			--if not IsSolo.Value then
			local Overhead = Instance.new("BillboardGui")
			Overhead.Name = "Overhead"
			Overhead.AlwaysOnTop = true
			Overhead.ExtentsOffsetWorldSpace = Vector3.new(0, -1, 0)
			Overhead.MaxDistance = 100
			Overhead.ResetOnSpawn = false
			Overhead.Size = UDim2.new(0, 56, 0, 14)
			Overhead.StudsOffsetWorldSpace = Vector3.new(0, 1.5, 0)
			Overhead:SetAttribute("IsNametag", true)
			local Nametag = Instance.new("TextLabel")
			Nametag.BackgroundTransparency = 1
			Nametag.Position = UDim2.new(0, 0, 0, -21)
			Nametag.Size = UDim2.new(1, 0, 1, 14)
			Nametag.Font = Enum.Font.GothamBold
			Nametag.TextColor3 = Color3.fromRGB(255, 255, 255)
			Nametag.TextSize = 14
			Nametag.TextStrokeTransparency = 0
			Nametag.Parent = Overhead
			local Healthbar = Instance.new("Frame")
			Healthbar.Name = "HealthBarContainer"
			Healthbar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			Healthbar.BorderSizePixel = 0
			Healthbar.Position = UDim2.new(0.5, -23, 1, -12)
			Healthbar.Size = UDim2.new(0, 46, 0, 7)
			Healthbar.Parent = Overhead
			local Bar = Instance.new("Frame")
			Bar.Name = "HealthBarContainer"
			Bar.BackgroundColor3 = Color3.fromRGB(129, 197, 22)
			Bar.BorderSizePixel = 0
			Bar.Position = UDim2.new(0.5, -23, 0, 0)
			Bar.Size = UDim2.new(1, 0, 1, 0)
			Bar.Parent = Healthbar
			
			local NametagTextStrokeTransparency = Nametag.TextStrokeTransparency

			local IsPlayer: Player? = Players:GetPlayerFromCharacter(HumanoidParent)

			Nametag.Text = HumanoidParent.Name

			Bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 0, 7)
			Healthbar.Visible = (humanoid.MaxHealth > 0)

			if IsPlayer then
				Overhead.PlayerToHideFrom = IsPlayer
					
					table.insert(Connections, DisplayConnection)

					if IsPlayer.Team then
						local isColor3 = IsPlayer.Team:GetAttribute("Color3") ~= nil
						local TeamColor = isColor3 and IsPlayer.Team:GetAttribute("Color3") or IsPlayer.Team.TeamColor.Color
						
						if not IsPlayer.Neutral then
							Nametag.TextColor3 = TeamColor
							--Nametag.TextColor3 = IsPlayer.Team.TeamColor.Color
						end
					end

				table.insert(Connections, IsPlayer:GetPropertyChangedSignal("Neutral"):Connect(function()					
					if IsPlayer.Team then
						if IsPlayer.Neutral then
							Nametag.TextColor3 = Color3.fromRGB(255, 255, 255)
						else
							local isColor3 = IsPlayer.Team:GetAttribute("Color3") ~= nil
							local TeamColor = isColor3 and IsPlayer.Team:GetAttribute("Color3") or IsPlayer.Team.TeamColor.Color
							
							--Nametag.TextColor3 = IsPlayer.Team.TeamColor.Color
							Nametag.TextColor3 = TeamColor
						end
					end
				end))

				table.insert(Connections, IsPlayer:GetPropertyChangedSignal("Team"):Connect(function()				
					if IsPlayer.Team then
						if not IsPlayer.Neutral then
							local isColor3 = IsPlayer.Team:GetAttribute("Color3") ~= nil
							local TeamColor = isColor3 and IsPlayer.Team:GetAttribute("Color3") or IsPlayer.Team.TeamColor.Color
							
							Nametag.TextColor3 = TeamColor
							--Nametag.TextColor3 = IsPlayer.Team.TeamColor.Color
						end
					end
				end))
			end

			Overhead.Parent = CurrentHead
			Overhead.Size = UDim2.new(0, Nametag.TextBounds.X * 2, 0, 14)
			CustomCamera:AddBillboard(Overhead);
			
			Nametag.Font = Enum.Font.Cartoon

			table.insert(Connections, Overhead.AncestryChanged:Connect(function(child: Instance, parent: Instance): ()
				for _, v in pairs(Connections) do
					v:Disconnect()
				end
				
				

				if parent then
					local GetHumanoid = parent:FindFirstChildOfClass("Humanoid")

					if GetHumanoid then
						self:ApplyHealthBar(GetHumanoid)
					else
						Overhead:Destroy()
					end
				end
			end))

			table.insert(Connections, humanoid.AncestryChanged:Connect(function(child: Instance, parent: Instance): ()
				if (not parent) or (not humanoid:IsDescendantOf(HumanoidParent)) then
					Overhead:Destroy()
				end
			end))

			table.insert(Connections, humanoid.HealthChanged:Connect(function(health: number): ()
				Bar.Size = UDim2.new(health / humanoid.MaxHealth, 0, 0, 7)
			end))

			table.insert(Connections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function(): ()
				Bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 0, 7)
				Healthbar.Visible = (humanoid.MaxHealth > 0)
			end))

			table.insert(Connections, HumanoidParent:GetPropertyChangedSignal("Name"):Connect(function(): ()
				Nametag.Text = HumanoidParent.Name
				
				--if HumanoidParent:GetAttribute("FakeName") then
				--	Nametag.Text = HumanoidParent:GetAttribute("FakeName")
				--end

				--if CurrentTimePeriod < 8 then
				--	CustomFont.displayString(Nametag.Text, Nametag.TextBounds.Y + 4, Nametag, NametagTextStrokeTransparency)
				--end
			end))

			table.insert(Connections, Nametag:GetPropertyChangedSignal("Text"):Connect(function(): ()
				Overhead.Size = UDim2.new(0, Nametag.TextBounds.X * 2, 0, 14)
			end))
		end
	end
end

return Humanoid
