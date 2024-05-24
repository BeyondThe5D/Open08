--!strict
-- https://devforum.roblox.com/t/release-notes-for-564/2196195/20
local BreakJoints
BreakJoints = function(root: BasePart | Model): ()
	if (not root) then
		return
	end
	
	if root:IsA("Model") then
		for _: number, child: Instance in root:GetChildren() do
			if child:IsA("BasePart") or child:IsA("Model") then
				BreakJoints(child)
			end
		end
	elseif root:IsA("BasePart") then
		for _: number, joint: Instance in root:GetJoints() do
			if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
				joint:Destroy()
			end
		end
	end
end

return BreakJoints
