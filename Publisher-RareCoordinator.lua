local function handleMessage(sender, rcMessage)
	local parts = string.split(rcMessage, "[^_]+")
	if #parts ~= 4 then return end

	local rare = { Zone = "Timeless Isle", SourceCharacter = sender, SourcePublisher = "RareCoordinator", Name = "FAKENAME-TODO" }
	rare.ID = tonumber(parts[2])

	local rcEventType = parts[3]
	if rcEventType == "dead" then
		rare.EventType = "Dead"
	end
	if rcEventType:starts("alive") then
		rare.EventType = "Alive"
		local loc = string.split(rcEventType, "[^,%-]+")
		if #loc == 3 then
			rare.X = tonumber(loc[2])
			rare.Y = tonumber(loc[3])
		end
		
		rare.Health = tonumber(string.sub(loc[1], 6))
		-- TODO: Set health priority (this goes down only in 10s)
	end

	RareShare:Publish(rare)
end

RareShare:SubscribeToChat("RCELVA", handleMessage)
