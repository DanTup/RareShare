-- Track which rares we announced, so we only announce deaths if we announced alives
-- This is to avoid lots of Dead announcements from multiple RareShare users that
-- were within range of the combat log announcement
local announcedRares = {}

local function AnnounceInChat(rare)
	if rare.MajorEvent and rare.AllowAnnouncing then
		if rare.EventType == "Alive" then
			SendChatMessage("[RareShare] "..rare.Name.." spotted around "..rare.X..","..rare.Y.." with "..rare.Health.."% HP!", "GUILD")
			announcedRares[rare.ID] = true
		elseif rare.EventType == "Dead" and announcedRares[rare.ID] then
			SendChatMessage("[RareShare] "..rare.Name.." has been killed!", "GUILD")
			announcedRares[rare.ID] = nil
		end
	end
end

RareShare:RegisterSubscriber(AnnounceInChat)
