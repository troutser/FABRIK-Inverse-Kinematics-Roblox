local IKController = {}
IKController.__index = IKController
local defaultLength = 8
function IKController.system(points, lengths)
	if not lengths then
		lengths = {}
	end
	local system = {
		points = points,
		connectors = {}
	}
	for i = 1, #points-1 do
		table.insert(system.connectors, IKController.connector(lengths[i] and lengths[i] or defaultLength))
	end
	setmetatable(system, IKController)
	
	return system
end
function IKController.connector(length, num)
	local connector = game.ReplicatedStorage.Leg:Clone()
	connector.Anchored = true
	connector.CanCollide = false
	connector.Parent = workspace
	
	return setmetatable({["connector"] = connector, ["length"] = length}, IKController)
end
function IKController:solve(iterations, goal, start)
	local points = self.points
	local connectors = self.connectors
	for _ = 1, iterations do

		self.points[#points] = goal
		for i = #points-1, 1, -1 do
			self.points[i] = points[i+1] + (points[i]-points[i+1]).Unit * connectors[i].length
		end
		self.points[1] = start
		for i = 2, #points do
			self.points[i] = points[i-1] + (points[i]-points[i-1]).Unit * connectors[i-1].length
		end
	end
end
function IKController:connect(p1,p2)
	local midp = (p1 + p2) * 0.5
	self.connector.CFrame = CFrame.new(midp, p2)
	self.connector.Size = Vector3.new(1,1,self.length)
end
function IKController:represent()
	for i, connector in pairs(self.connectors) do
		connector:connect(self.points[i], self.points[i+1])
	end
end
return IKController
