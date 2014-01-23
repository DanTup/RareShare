function handleTarget()
	if not UnitExists("target") then
		return
	end
	-- Bail out if target is not a rare/rareelite
	local targetType = UnitClassification("target")
	if targetType ~= "rare" and targetType ~= "rareelite" then return end

	local rareName, _ = UnitName("target")
	local rareHealth = toint(UnitHealth("target") / UnitHealthMax("target") * 100)
	SetMapToCurrentZone()
	local rareX, rareY = GetPlayerMapPosition("player")
	rareX = toint(rareX * 100 + .5)
	rareY = toint(rareY * 100 + .5)
	local rareID = UnitID("target")

	if rareHealth < 1 then return end

	local rare = {
		ID = toint(rareID),
		Name = rareName,
		Zone = GetZoneText(),
		EventType = "Alive",
		Health = rareHealth,
		X = rareX,
		Y = rareY,
		Time = time(),
		AllowAnnouncing = true,
		SourceCharacter = UnitName("player"),
		SourcePublisher = "RareShareTargettedMob"
	}

	RareShare:Publish(rare)
end

function handleTargetHealth(unit)
	if unit == "target" then
		handleTarget()
	end
end

local function onChat(message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter, guid)
	if channelName == chatChannel then
		handler(sender, message)
	end
end

function onEvent(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		handleTarget()
	end

	if event == "UNIT_HEALTH" then
		handleTargetHealth(...)
	end
end

-- We want to provide updates even if the rare health is not changing (eg. player chasing Evermaw around)
-- but we don't want to do this every frame, so just poll every 5 seconds
local timeTillUpdate = 5.0
function onUpdate(self, elapsed)
	-- Do absolutely nothing if there's no target
	if not UnitExists("target") then return end

	-- Count down till next required update
	timeTillUpdate = timeTillUpdate - elapsed

	if timeTillUpdate < 0 then
		timeTillUpdate = 5.0

		handleTarget()
	end
end

local frame = CreateFrame("MessageFrame", "RareShareTargettedMob")
frame:SetScript("OnEvent", onEvent)
frame:SetScript("OnUpdate", onUpdate)
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_HEALTH")
