local testRareAlive = {
	ID = 1,
	Name = "Danny Mob",
	Zone = "Timeless Isle",
	EventType = "Alive",
	Health = 90,
	X = 12,
	Y = 19,
	MajorEvent = true
}

local testRareDead = {
	ID = 1,
	Zone = "Timeless Isle",
	EventType = "Dead",
	MajorEvent = true
}

local function slashHandler(msg)
	if msg == "alive" then
		RareShare:Publish(testRareAlive)
	elseif msg == "dead" then
		RareShare:Publish(testRareDead)
	end
end

SLASH_RARESHARE1 = '/rstest'
SlashCmdList["RARESHARE"] = slashHandler