function handleCombatLogDeaths(timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags)
	if event ~= "UNIT_DIED" then return end

	local rareID = UnitIDFromGuid(destGUID)

	local rare = {
		ID = toint(rareID),
		Name = destName,
		Zone = GetZoneText(),
		EventType = "Dead",
		Time = toint(timeStamp),
		AllowAnnouncing = true,
		SourceCharacter = UnitName("player"),
		SourcePublisher = "RareShareCombatLog"
	}

	RareShare:Publish(rare)
end

function onEvent(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		handleCombatLogDeaths(...)
	end
end

local frame = CreateFrame("MessageFrame", "RareShareCombatLogDeaths")
frame:SetScript("OnEvent", onEvent)
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
