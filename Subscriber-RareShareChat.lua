local rareShareChatChannel = -1
local rareShareSep = "~"

local function AnnounceInRareShareChat(rare)
	-- Only share Alive and Dead events (eg. no Decays)
	if rare.EventType ~= "Alive" and rare.EventType ~= "Dead" then return end

	if rareShareChatChannel == -1 then
		rareShareChatChannel, _, _ = GetChannelName("DANTUPRARESHARE")
	end

	if rareShareChatChannel ~= nil and rareShareChatChannel > 0 and not rare.SuppressSharing then
		local message = rare.ID..rareShareSep..nilToWordNil(rare.Name)..rareShareSep..nilToWordNil(rare.Zone)..rareShareSep..rare.EventType..rareShareSep..nilToWordNil(rare.Health)..rareShareSep..nilToWordNil(rare.X)..rareShareSep..nilToWordNil(rare.Y)..rareShareSep..nilToWordNil(rare.Time)
		SendChatMessage(message, "CHANNEL", nil, rareShareChatChannel)
	end
end

RareShare:RegisterSubscriber(AnnounceInRareShareChat)
