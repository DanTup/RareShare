testRare = {
	ID = 1,
	Name = "Danny Mob",
	Zone = "Timeless Isle",
	EventType = "Alive",
	Health = 90,
	X = 12,
	Y = 19,
	Time = time(),
	SourceCharacter = "Shoomoo",
	SourcePublisher = "Test",
	AllowAnnouncing = true
}

testRareNotTimelessIsle = {
	ID = 1,
	Name = "Danny Mob",
	Zone = "Stormwind City",
	EventType = "Alive",
	Health = 90,
	X = 12,
	Y = 19,
	Time = time(),
	SourceCharacter = "Shoomoo",
	SourcePublisher = "Test",
	AllowAnnouncing = true
}

testRareDead = {
	ID = 1,
	Zone = "Timeless Isle",
	EventType = "Dead",
	Time = time(),
	SourceCharacter = "Shoomoo",
	SourcePublisher = "Test",
	AllowAnnouncing = true
}

testInvalidRare = {
	ID = 1,
	Name = "Danny Mob",
	Zone = "Timeless Isle",
	EventType = "Alive",
	Time = time(),
	AllowAnnouncing = true
}
