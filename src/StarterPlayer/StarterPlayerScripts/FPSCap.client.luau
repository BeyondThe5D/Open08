local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MaxFPS = 1 / 30

while true do
	local t0 = tick()
	RunService.Heartbeat:Wait()
	repeat until (t0 + MaxFPS) < tick()
end