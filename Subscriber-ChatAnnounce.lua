-- Track which rares we announced, so we only announce deaths if we announced alives
-- This is to avoid lots of Dead announcements from multiple RareShare users that
-- were within range of the combat log announcement
local announcedRares = {}

local function getGeneralChat(id, name, ...)
   if id and name then
	  if string.find(name, GENERAL) then
		 return id
	  end
	  return getGeneralChat(...)
   end
end

local function AnnounceInChat(rare)
	-- Never do any sort of chat announcing if disabled
	if rare.Zone == "Timeless Isle" and not RareShare:AllowAnnouncingTimelessIsle() then
		return
	elseif rare.Zone ~= "Timeless Isle" and not RareShare:AllowAnnouncing() then
		return
	end

	local channelNumber = getGeneralChat(GetChannelList())
	if channelNumber == 0 or channelNumber == nil then return end

	if rare.MajorEvent and rare.AllowAnnouncing then
		if rare.EventType == "Alive" and rare.Health >= 50 then -- Only announce in chat when the mob has enough HP for it to be worthwhile
			SendChatMessage("[RareShare] "..rare.Name.." spotted around "..rare.X..","..rare.Y.." with "..rare.Health.."% HP!", "CHANNEL", nil, channelNumber)
			announcedRares[rare.ID] = true
		elseif rare.EventType == "Dead" and announcedRares[rare.ID] then
			SendChatMessage("[RareShare] "..rare.Name.." has been killed!", "CHANNEL", nil, channelNumber)
			announcedRares[rare.ID] = nil
		end
	end
end

RareShare:RegisterSubscriber(AnnounceInChat)
