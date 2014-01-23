-- Rare data format:
-- Table:
-- {
-- 	ID						int		required
-- 	Name					string	required if EventType == "Alive"; but automatically provided to Subscribers for Dead events
--	Zone					string	required if EventType == "Alive"; but automatically provided to Subscribers for Dead events
--	EventType				string	"Alive", "Dead" or "Decay" (Decay = fired when an Alive mob has not been seen for some time; but can only be raised internally)
-- 	Health 					int		required if EventType == "Alive"
--	X						int		required if EventType == "Alive"
--	Y						int		required if EventType == "Alive"
--	Time					int		required
--	SuppressAnnouncements	bool	true if we shouldn't announce this (eg. it came from another RareShare that will have announced it)
--	MajorEvent				bool	true if this event is major (first sight, death) that should be shown to a user (false/nil for incremental updates, like waypoint names)
--	SourceCharacter			string	required; name of character this event originated from
--	SourcePublisher			string	required; publisher that raised this event
-- }

local isDebugMode = false
local filteredSubscribers = {}
local unfilteredSubscribers = {}
local knownRares = {}
local latestRareMessages = {}
local chatSubscribers = {} -- NOTE: This doesn't get reset, as registered handlers are added at runtime; it's all setup stuff

RareShare = {}

-- Used for testing; need to be able to reset everything back to clean so that
-- each test gets a clean run
function RareShare:ResetState()
	filteredSubscribers = {}
	unfilteredSubscribers = {}
	knownRares = {}
	latestRareMessages = {}
end

function RareShare:IsDebugMode() return isDebugMode end
function RareShare:ToggleDebugMode() isDebugMode = not isDebugMode end
function RareShare:EnableDebugMode() isDebugMode = true end

function RareShare:ValidateRare(rare)
	if rare == nil then return "rare == nil" end
	if rare.SourceCharacter == nil then return "SourceCharacter" end
	if rare.SourcePublisher == nil then return "SourcePublisher" end
	if rare.ID == nil then return "ID" end
	if rare.Zone == nil then return "Zone" end
	if rare.Time == nil then return "Time" end
	if rare.EventType ~= "Alive" and rare.EventType ~= "Dead" then return "EventType" end
	if rare.EventType == "Alive" then
		if rare.Name == nil then return "Name" end
		if rare.Health == nil then return "Health" end
		if rare.X == nil then return "X" end
		if rare.Y == nil then return "Y" end
	end
	return nil
end

function RareShare:RegisterSubscriber(sub, includeOutOfZoneEvents)
	if includeOutOfZoneEvents then
		unfilteredSubscribers[#unfilteredSubscribers + 1] = sub
	else
		filteredSubscribers[#filteredSubscribers + 1] = sub
	end
end

function RareShare:Publish(rare)
	local validationResults = RareShare:ValidateRare(rare)
	if validationResults ~= nil then
		if RareShare:IsDebugMode() and RareShareTests == nil then print("    Invalid rare! "..validationResults) end
		return
	end

	-- Check that this message isn't older than one we already parsed
	-- We're allowing messages with the *same* time, simply because lua time() is to the second, and it's better to dupe than miss events
	if latestRareMessages[rare.ID] and latestRareMessages[rare.ID] > rare.Time then
		if RareShare:IsDebugMode() and RareShareTests == nil then print("    Ignoring out-of-date message") end
		return
	end

	-- Ignore unreliable health estimates that say 0 (RareCoordinator sends 0 when < 10%)
	if rare.HealthPriority and rare.HealthPriority > 1 and rare.Health == 0 then
		if RareShare:IsDebugMode() and RareShareTests == nil then print("    Ignoring bad health message") end
		return
	end

	-- Ignore unreliable health estimates if they're within the threshold (eg. don't overwrite a RareShare 25% with a RareCoorindator 20%, but do overwrite it with a RareCoorindator 10%)
	if rare.HealthPriority and rare.HealthPriority > 1 and knownRares[rare.ID] then
		if knownRares[rare.ID].Health - rare.Health <= rare.HealthPriority then
			if RareShare:IsDebugMode() and RareShareTests == nil then print("    Ignoring bad health message") end
			return
		end
	end

	-- Don't re-broadcast events unless something has changed (X, Y, Zone, Health unless last event was more than x seconds ago)
	if knownRares[rare.ID] then
		local known = knownRares[rare.ID]
		if known.X == rare.X and known.Y == rare.Y and known.Health == rare.Health and rare.Time < known.Time + 5 then
			if RareShare:IsDebugMode() and RareShareTests == nil then print("    Ignoring similar message") end
			return
		end
	end

	-- Remember the time of the last event
	latestRareMessages[rare.ID] = rare.Time

	-- Ignore any non-Alive events if we weren't tracking the rare
	if rare.EventType ~= "Alive" and not knownRares[rare.ID] then
		return
	end
	
	-- Set as Major event if it's a death, or alive but we didn't already have it
	rare.MajorEvent = (rare.EventType == "Dead" or (rare.EventType == "Alive" and not knownRares[rare.ID]))

	-- Death events don't always have all data; but we can get them from the previous Alive event
	if knownRares[rare.ID] then
		if rare.Name == nil then rare.Name = knownRares[rare.ID].Name end
		if rare.Zone == nil then rare.Zone = knownRares[rare.ID].Zone end
	end

	-- Keep track of the rare if it's alive, otherwise remove it from our tracking list
	if rare.EventType == "Alive" then
		knownRares[rare.ID] = rare
	else
		knownRares[rare.ID] = nil
	end

	-- Always notify subscribers that wanted unfiltered events
	for _, sub in pairs(unfilteredSubscribers) do
		sub(rare)
	end

	-- Only notify filtered subscribers if the event is for this zone
	if rare.Zone == GetZoneText() then
		for _, sub in pairs(filteredSubscribers) do
			local status, err = pcall(function() sub(rare) end)
			if not status and RareShare:IsDebugMode() then
				print("    RareShare subscriber error: "..err)
			end
		end
	end
end

function RareShare:SubscribeToChat(chatChannel, handler)
	local function onChat(message, sender, language, channelString, target, flags, unknown, channelNumber, channelName, unknown, counter, guid)
		if channelName == chatChannel then
			handler(sender, message)
		end
	end

	local function onEvent(self, event, ...)
		if event == "CHAT_MSG_CHANNEL" then
			onChat(...)
		end
	end

	local frame = CreateFrame("MessageFrame", "RareShare"..chatChannel)

	-- HACK: We need to wait some time for the default channels to be joined, otherwise we push General down from 1, and things go wonky
	local timeTillJoinChannels = 5.0
	local function onUpdate(self, elapsed)
		timeTillJoinChannels = timeTillJoinChannels - elapsed

		if timeTillJoinChannels < 0 then
			JoinTemporaryChannel(chatChannel, nil, frame:GetID())
			frame:SetScript("OnUpdate", nil)
		end
	end

	frame:SetScript("OnEvent", onEvent)
	frame:SetScript("OnUpdate", onUpdate)
	frame:RegisterEvent("CHAT_MSG_CHANNEL")

	local channelSubscribers = chatSubscribers[chatChannel] or {}
	channelSubscribers[#channelSubscribers + 1] = handler
	chatSubscribers[chatChannel] = channelSubscribers
end

function RareShare:GetChannelSubscribersForTesting()
	return chatSubscribers
end
