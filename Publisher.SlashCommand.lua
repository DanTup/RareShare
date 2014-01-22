local testRareAlive = {
	ID = 1,
	Name = "Danny Mob",
	Zone = GetZoneText(),
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
	Zone = "Fake Zone",
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
	Zone = GetZoneText(),
	EventType = "Dead",
	MajorEvent = true,
	SourceCharacter = GetUnitName("player"),
	SourcePublisher = "SlashCommand"
}

local testRareDeadOtherZone = {
	ID = 1,
	Zone = "Fake Zone",
	EventType = "Dead",
	MajorEvent = true,
	SourceCharacter = GetUnitName("player"),
	SourcePublisher = "SlashCommand"
}

local function slashHandler(msg)
	if msg == "alive" then
		RareShare:Publish(testRareAlive)
	elseif msg == "dead" then
		RareShare:Publish(testRareDead)
	elseif msg == "alive other" then
		RareShare:Publish(testRareAliveOtherZone)
	elseif msg == "dead other" then
		RareShare:Publish(testRareDeadOtherZone)
	else
		print("Allowed commands:")
		print("    /rstest alive        Sends a current-zone alive alert")
		print("    /rstest dead         Sends a current-zone dead alert")
		print("    /rstest alive other  Sends an other-zone alive alert")
		print("    /rstest dead other   Sends an other-zone dead alert")
	end
end

SLASH_RARESHARE1 = '/rstest'
SlashCmdList["RARESHARE"] = slashHandler
