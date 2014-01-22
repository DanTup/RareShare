testRare = {
	ID = 1,
	Name = "Danny Mob",
	Zone = "Stormwind City",
	EventType = "Alive",
	Health = 90,
	X = 12,
	Y = 19,
	SourceCharacter = "Shoomoo",
	SourcePublisher = "Test"
}

testRareDead = {
	ID = 1,
	Zone = "Stormwind City",
	EventType = "Dead",
	SourceCharacter = "Shoomoo",
	SourcePublisher = "Test"
}

testInvalidRare = {
	ID = 1,
	Name = "Danny Mob",
	Zone = "Stormwind City",
	EventType = "Alive"
}

function test_publish_and_subscribe()
	local eventFiredCorrectly = false
	local testSubscriber = function(rare)
		eventFiredCorrectly = (rare == testRare)
	end
	RareShare:RegisterSubscriber(testSubscriber)

	RareShare:Publish(testRare)
	assert(eventFiredCorrectly)
end

function test_multiple_subscribers()
	local event1FiredCorrectly = false
	local testSubscriber1 = function(rare)
		eventFired1Correctly = (rare == testRare)
	end
	RareShare:RegisterSubscriber(testSubscriber1)

	local event2FiredCorrectly = false
	local testSubscriber2 = function(rare)
		eventFired2Correctly = (rare == testRare)
	end
	RareShare:RegisterSubscriber(testSubscriber2)

	RareShare:Publish(testRare)
	assert(eventFired1Correctly)
	assert(eventFired2Correctly)
end

function test_valid_rare_is_published()
	local eventFiredCorrectly = false
	local testSubscriber = function(rare)
		eventFiredCorrectly = (rare == testRare)
	end
	RareShare:RegisterSubscriber(testSubscriber)
	RareShare:Publish(testRare)
	assert(eventFiredCorrectly)
end

function test_invalid_rare_is_not_published()
	local eventFired = false
	local testSubscriber = function(rare)
		eventFired = true
	end
	RareShare:RegisterSubscriber(testSubscriber)
	RareShare:Publish(testInvalidRare)
	assert(not eventFired)
end