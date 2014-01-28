local function handleMessage(sender, message)
	-- Ignore any messages sent by self
	if sender == UnitName("player") then return end

	local data = RareShare:StringSplit(message, "[^~]+")

	-- If we don't have at least the information we expect, bail
	if #data < 8 then return end

	local rare = {
		ID = RareShare:ToInt(data[1]),
		Name = RareShare:WordNilToNil(data[2]),
		Zone = RareShare:WordNilToNil(data[3]),
		EventType = data[4],
		Health = RareShare:ToInt(RareShare:WordNilToNil(data[5])),
		X = RareShare:ToInt(RareShare:WordNilToNil(data[6])),
		Y = RareShare:ToInt(RareShare:WordNilToNil(data[7])),
		Time = RareShare:ToInt(RareShare:WordNilToNil(data[8])),
		SuppressSharing = true, -- It's already been shared (hence this code running)
		SourceCharacter = sender,
		SourcePublisher = "RareShareChat"
	}

	RareShare:Publish(rare)
end

RareShare:SubscribeToChat("DANTUPRARESHARE", handleMessage)
