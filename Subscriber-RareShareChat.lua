local rareShareChatChannel = -1
local rareShareSep = "~"

local function AnnounceInRareShareChat(rare)
	if rareShareChatChannel == -1 then
		rareShareChatChannel, _, _ = GetChannelName("DANTUPRARESHARE")
	end

	if rareShareChatChannel ~= nil and rareShareChatChannel > 0 and not rare.SuppressAnnouncements then
		local message = rare.ID..rareShareSep..nilToWordNil(rare.Name)..rareShareSep..nilToWordNil(rare.Zone)..rareShareSep..rare.EventType..rareShareSep..nilToWordNil(rare.Health)..rareShareSep..nilToWordNil(rare.X)..rareShareSep..nilToWordNil(rare.Y)..rareShareSep..nilToWordNil(rare.Time)
		SendChatMessage(message, "CHANNEL", nil, rareShareChatChannel)
	end
end

RareShare:RegisterSubscriber(AnnounceInRareShareChat)
