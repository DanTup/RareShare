﻿local function handleMessage(sender, message)
	local data = string.split(message, "[^~]+")

	-- If we don't have at least the information we expect, bail
	if #data < 7 then return end

	local rare = {
		ID = toint(data[1]),
		Name = wordNilToNil(data[2]),
		Zone = wordNilToNil(data[3]),
		EventType = data[4],
		Health = toint(wordNilToNil(data[5])),
		X = toint(wordNilToNil(data[6])),
		Y = toint(wordNilToNil(data[7])),
		SuppressAnnouncements = true, -- Since this came from RareShare; the original sender will have announced it
		SourceCharacter = sender,
		SourcePublisher = "RareShareChat"
	}

	RareShare:Publish(rare)
end

RareShare:SubscribeToChat("DANTUPRARESHARE", handleMessage)