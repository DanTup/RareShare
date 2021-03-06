﻿local testRareAlive = {
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
	testRareAlive.Time = time()
	testRareDead.Time = time()
	testRareAliveOtherZone.Time = time()
	testRareDeadOtherZone.Time = time()

	if msg == "dump" then
		local knownRares = RareShare:GetKnownRaresForTesting()
		print("|cff9999ffRareShare:|r Known rares:")
		for _, rare in pairs(knownRares) do
			print("|cff9999ffRareShare:|r     "..rare.ID..", "..rare.Name.." "..rare.X..","..rare.Y.." ("..rare.Health.."%) @ "..rare.Time)
		end
	elseif msg == "debug" then
		RareShare:ToggleDebugMode()
		if RareShare:IsDebugMode() then
			print("|cff9999ffRareShare:|r Debug mode enabled")
		else
			print("|cff9999ffRareShare:|r Debug mode disabled")
		end
	elseif msg == "announceexternal" then
		RareShare:ToggleAllowAnnouncingOfExternalEvents()
		if RareShare:AllowAnnouncingOfExternalEvents() then
			print("|cff9999ffRareShare:|r External events will now be announced")
		else
			print("|cff9999ffRareShare:|r External events will no longer be announced")
		end
	elseif msg == "alive" then
		RareShare:Publish(RareShare:Clone(testRareAlive))
	elseif msg == "dead" then
		RareShare:Publish(RareShare:Clone(testRareDead))
	elseif msg == "alive other" then
		RareShare:Publish(RareShare:Clone(testRareAliveOtherZone))
	elseif msg == "dead other" then
		RareShare:Publish(RareShare:Clone(testRareDeadOtherZone))
	else
		print("|cff9999ffRareShare:|r Allowed commands:")
		print("|cff9999ffRareShare:|r     /rstest dump    -    Dump known rares")
		print("|cff9999ffRareShare:|r     /rstest debug    -    Toggles debug mode ("..(RareShare:IsDebugMode() and "|cff99ff99Enabled|r" or "|cffff9999Disabled|r")..")")
		print("|cff9999ffRareShare:|r     /rstest announceexternal    -    Toggles announcing non-RareShare events ("..(RareShare:AllowAnnouncingOfExternalEvents() and "|cff99ff99Enabled|r" or "|cffff9999Disabled|r")..")")
		print("|cff9999ffRareShare:|r     /rstest alive    -    Sends a current-zone alive alert")
		print("|cff9999ffRareShare:|r     /rstest dead    -    Sends a current-zone dead alert")
		print("|cff9999ffRareShare:|r     /rstest alive other    -    Sends an other-zone alive alert")
		print("|cff9999ffRareShare:|r     /rstest dead other    -    Sends an other-zone dead alert")
	end
end

SLASH_RARESHARETEST1 = '/rstest'
SlashCmdList["RARESHARETEST"] = slashHandler
