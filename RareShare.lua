-- Rare data format:
-- Table:
-- {
-- 	ID			int	required
-- 	Name			string	required if EventType == "Alive"
--	Zone			string	required
--	EventType		string	"Alive", "Dead" or "Decay" (Decay = fired when an Alive mob has not been seen for some time; but can only be raised internally)
-- 	Health 			int	required if EventType == "Alive"
--	X			int	required if EventType == "Alive"
--	Y			int	required if EventType == "Alive"
--	SuppressAnnouncements	bool	true if we shouldn't announce this (eg. it came from another RareShare that will have announced it)
--	MajorEvent		bool	true if this event is major (first sight, death) that should be shown to a user (false/nil for incremental updates, like waypoint names)
-- }

RareShare = {}
local subscribers = {}

function RareShare:IsDebugMode() return true end

function RareShare:ValidateRare(rare)
	if rare == nil then return false end
	if rare.ID == nil then return false end
	if rare.Zone == nil then return false end
	if rare.EventType ~= "Alive" and rare.EventType ~= "Dead" then return false end
	if rare.EventType == "Alive" then
		if rare.Name == nil then return false end
		if rare.Health == nil then return false end
		if rare.X == nil then return false end
		if rare.Y == nil then return false end
	end
	return true
end

function RareShare:RegisterSubscriber(sub)
	subscribers[#subscribers + 1] = sub
end

function RareShare:Publish(rare)
	if not RareShare:ValidateRare(rare) then
		if RareShare:IsDebugMode() then print("Invalid rare! "..debug.traceback()) end
		return
	end

	for _, sub in pairs(subscribers) do
		sub(rare)
	end
end