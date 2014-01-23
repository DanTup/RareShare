function test_publish_and_subscribe()
	local eventFiredCorrectly = false
	RareShare:RegisterSubscriber(
		function(rare)
			eventFiredCorrectly = (rare == testRare)
		end
	)

	RareShare:Publish(testRare)
	assert(eventFiredCorrectly)
end

function test_multiple_subscribers()
	local event1FiredCorrectly = false
	local event2FiredCorrectly = false

	RareShare:RegisterSubscriber(
		function(rare)
			eventFired1Correctly = (rare == testRare)
		end
	)
	RareShare:RegisterSubscriber(
		function(rare)
			eventFired2Correctly = (rare == testRare)
		end
	)

	RareShare:Publish(testRare)
	assert(eventFired1Correctly)
	assert(eventFired2Correctly)
end

function test_valid_rare_is_published()
	local eventFiredCorrectly = false
	RareShare:RegisterSubscriber(
		function(rare)
			eventFiredCorrectly = (rare == testRare)
		end
	)
	RareShare:Publish(testRare)
	assert(eventFiredCorrectly)
end

function test_invalid_rare_is_not_published()
	local eventFired = false
	RareShare:RegisterSubscriber(
		function(rare)
			eventFired = true
		end
	)
	RareShare:Publish(testInvalidRare)
	assert(not eventFired)
end

function test_only_first_alive_event_is_considered_major()
	local numberOfEvents = 0
	local numberOfMajorEvents = 0
	RareShare:RegisterSubscriber(
		function(rare)
			numberOfEvents = numberOfEvents + 1
			if rare.MajorEvent then
				numberOfMajorEvents = numberOfMajorEvents + 1
			end
		end
	)
	RareShare:Publish(testRare)
	RareShare:Publish(testRare)
	assert(numberOfEvents == 2)
	assert(numberOfMajorEvents == 1)
end

function test_death_events_are_always_major()
	local numberOfEvents = 0
	local numberOfMajorEvents = 0
	RareShare:RegisterSubscriber(
		function(rare)
			if rare.EventType == "Dead" then
				numberOfEvents = numberOfEvents + 1
				if rare.MajorEvent then
					numberOfMajorEvents = numberOfMajorEvents + 1
				end
			end
		end
	)
	RareShare:Publish(testRare)
	RareShare:Publish(testRareDead)
	RareShare:Publish(testRare)
	RareShare:Publish(testRareDead)
	assert(numberOfEvents == 2)
	assert(numberOfMajorEvents == 2)
end

function test_subscribers_get_current_zone_events_by_default()
	local eventFiredCorrectly = false
	RareShare:RegisterSubscriber(
		function(rare)
			eventFiredCorrectly = (rare == testRare)
		end
	)

	RareShare:Publish(testRare)
	assert(eventFiredCorrectly)
end

function test_subscribers_do_not_get_other_zone_events_by_default()
	RareShareTests:SetZone("Stormwind City")
	local eventFired = false
	RareShare:RegisterSubscriber(
		function(rare)
			eventFired = true
		end
	)

	RareShare:Publish(testRare)
	assert(not eventFired)
end

function test_subscribers_do_get_other_zone_events_if_requested()
	RareShareTests:SetZone("Stormwind City")
	local eventFiredCorrectly = false
	RareShare:RegisterSubscriber(
		function(rare)
			eventFiredCorrectly = (rare == testRare)
		end,
		true
	)

	RareShare:Publish(testRare)
	assert(eventFiredCorrectly)
end

function test_rare_coordinator_messages_are_parsed_correctly()
	local broadcastRare = nil
	RareShare:RegisterSubscriber(
		function(rare)
			broadcastRare = rare
		end
	)

	RareShareTests:BroadcastChat("RCELVA", "Krackle", "[RCELVA]5.4.1-4_72775_alive50,12-34_56789_")
	assert(broadcastRare ~= nil)
	assert(broadcastRare.ID == 72775)
	assert(broadcastRare.Name == "Bufo")
	assert(broadcastRare.EventType == "Alive")
	assert(broadcastRare.Health == 50)
	assert(broadcastRare.X == 12)
	assert(broadcastRare.Y == 34)
	assert(broadcastRare.SourceCharacter == "Krackle")
	assert(broadcastRare.SourcePublisher == "RareCoordinator")
end

function test_out_of_date_messages_get_ignored()
	local message1 = clone(testRare) -- 100%
	local message2 = clone(testRare) -- 50%
	local message3 = clone(testRareDead) -- Dead

	message1.Time = 10
	message2.Time = 20
	message3.Time = 30
	
	local receivedMessageTimes = {}
	RareShare:RegisterSubscriber(
		function(rare)
			receivedMessageTimes[#receivedMessageTimes + 1] = rare.Time
		end
	)

	RareShare:Publish(message1)
	RareShare:Publish(message2)
	RareShare:Publish(message1) -- Re-broadcast of old message, should be ignored
	RareShare:Publish(message3)
	RareShare:Publish(message2) -- Re-broadcast of old alive message, when mob is now dead!

	-- Ensure we only got the three messages in the correct order, despite the transmission of old mssages
	assert_tables_eq(receivedMessageTimes, { 10, 20, 30 })
end
