local testRareAlive = {
	ID = 1,
	Name = "Danny Mob",
	EventType = "Alive",
	Health = 90,
	X = 12,
	Y = 19,
	MajorEvent = true,
	SourceCharacter = GetUnitName("player"),
	SourcePublisher = "SlashCommand"
}

local testRareAliveOtherZone = {
	ID = 1,
	Name = "Danny Mob",
	EventType = "Alive",
	Health = 90,
	X = 12,
	Y = 19,
	MajorEvent = true,
	SourceCharacter = GetUnitName("player"),
	SourcePublisher = "SlashCommand"
}

local testRareDead = {
	ID = 1,
	EventType = "Dead",
	MajorEvent = true,
	SourceCharacter = GetUnitName("player"),
	SourcePublisher = "SlashCommand"
}

local testRareDeadOtherZone = {
	ID = 1,
	EventType = "Dead",
	MajorEvent = true,
	SourceCharacter = GetUnitName("player"),
	SourcePublisher = "SlashCommand"
}

local function slashHandler(msg)
	-- Update the zone; we can't set this at load, because we may change zone and then send test broadcasts
	testRareAlive.Zone = GetZoneText()
	testRareDead.Zone = GetZoneText()
	testRareAliveOtherZone.Zone = "Fake Zone"
	testRareDeadOtherZone.Zone = "Fake Zone"

	if msg == "debug" then
		RareShare:ToggleDebugMode()
		if RareShare:IsDebugMode() then
			print("|cff9999ffRareShare:|r Debug mode enabled")
		else
			print("|cff9999ffRareShare:|r Debug mode disabled")
		end
	elseif msg == "alive" then
		RareShare:Publish(testRareAlive)
	elseif msg == "dead" then
		RareShare:Publish(testRareDead)
	elseif msg == "alive other" then
		RareShare:Publish(testRareAliveOtherZone)
	elseif msg == "dead other" then
		RareShare:Publish(testRareDeadOtherZone)
	else
		print("|cff9999ffRareShare:|rAllowed commands:")
		print("|cff9999ffRareShare:|r    /rstest debug        Toggles debug mode")
		print("|cff9999ffRareShare:|r    /rstest alive        Sends a current-zone alive alert")
		print("|cff9999ffRareShare:|r    /rstest dead         Sends a current-zone dead alert")
		print("|cff9999ffRareShare:|r    /rstest alive other  Sends an other-zone alive alert")
		print("|cff9999ffRareShare:|r    /rstest dead other   Sends an other-zone dead alert")
	end
end

SLASH_RARESHARE1 = '/rstest'
SlashCmdList["RARESHARE"] = slashHandler
