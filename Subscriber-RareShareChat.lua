local rareShareChatChannel = -1
local rareShareSep = "~"

local function ShareViaChat(rare)
	-- Only share Alive and Dead events (eg. no Decays)
	if rare.EventType ~= "Alive" and rare.EventType ~= "Dead" then return end

	if rareShareChatChannel == -1 then
		rareShareChatChannel, _, _ = GetChannelName("DANTUPRARESHARE")
	end

	if rareShareChatChannel ~= nil and rareShareChatChannel > 0 and not rare.SuppressSharing then
		local message = rare.ID..rareShareSep..RareShare:NilToWordNil(rare.Name)..rareShareSep..RareShare:NilToWordNil(rare.Zone)..rareShareSep..rare.EventType..rareShareSep..RareShare:NilToWordNil(rare.Health)..rareShareSep..RareShare:NilToWordNil(rare.X)..rareShareSep..RareShare:NilToWordNil(rare.Y)..rareShareSep..RareShare:NilToWordNil(rare.Time)
		SendChatMessage(message, "CHANNEL", nil, rareShareChatChannel)
	end
end

RareShare:RegisterSubscriber(ShareViaChat)
