local waypoints = {}

local function UpdateWaypoints(rare)
	if TomTom == nil then return end

	-- Remove any existing waypoint
	local existingPoint = waypoints[rare.ID]
	if existingPoint ~= nil then
		TomTom:RemoveWaypoint(existingPoint)
		waypoints[rare.ID] = nil
	end

	-- If the event came from the current character, don't create a Waypoint; they clearly know where it is!
	if rare.SourceCharacter == UnitName("player") then return end

	if rare.EventType == "Alive" then
		local waypointName = rare.Name.." ("..rare.Health.."% HP)    [RareShare]"
		local newPoint = TomTom:AddWaypoint(rare.X, rare.Y, waypointName, false)
		waypoints[rare.ID] = newPoint
	end
end

RareShare:RegisterSubscriber(UpdateWaypoints)
