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
--	AllowAnnouncing			bool	true if we're allowed to announce this (eg. we discovered it)
--	SuppressSharing			bool	true if we shouldn't share this (eg. it came from another RareShare and everybody will have received it)
--	MajorEvent				bool	true if this event is major (first sight, death) that should be shown to a user (false/nil for incremental updates, like waypoint names)
--	SourceCharacter			string	required; name of character this event originated from
--	SourcePublisher			string	required; publisher that raised this event
-- }

local isDebugMode = false
local allowAnnouncingOfExternalEvents = false
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

-- Default settings, used when the item s not found in the users settings
local rareShareDefaultSettings = {
}

local function getSetting(name)
	RareShareSettings = RareShareSettings or {}
	local userSetting = RareShareSettings[name]
	if userSetting ~= nil then
		return userSetting
	else
		return rareShareDefaultSettings[name]
	end
end

local function setSetting(name, value)
	RareShareSettings = RareShareSettings or {}
	RareShareSettings[name] = value
end

function RareShare:IsDebugMode() return isDebugMode end
function RareShare:ToggleDebugMode() isDebugMode = not isDebugMode end
function RareShare:EnableDebugMode() isDebugMode = true end

function RareShare:AllowAnnouncingOfExternalEvents() return allowAnnouncingOfExternalEvents end
function RareShare:ToggleAllowAnnouncingOfExternalEvents() allowAnnouncingOfExternalEvents = not allowAnnouncingOfExternalEvents end
function RareShare:EnableAnnouncingOfExternalEvents() allowAnnouncingOfExternalEvents = true end

function RareShare:ValidateRare(rare)
	if rare == nil then return "rare == nil" end
	if rare.SourceCharacter == nil then return "SourceCharacter" end
	if rare.SourcePublisher == nil then return "SourcePublisher" end
	if rare.ID == nil then return "ID" end
	if rare.Time == nil then return "Time" end
	if rare.EventType ~= "Alive" and rare.EventType ~= "Dead" and rare.EventType ~= "Decay" then return "EventType" end
	if rare.EventType == "Alive" then
		if rare.Name == nil then return "Name" end
		if rare.Zone == nil then return "Zone" end
		if rare.Health == nil then return "Health" end
		if rare.X == nil then return "X" end
		if rare.Y == nil then return "Y" end
	end
	return nil
end

local function log(message)
	if RareShare:IsDebugMode() and RareShareTests == nil then
		print("|cff9999ffRareShare Debug:|r "..message)
	end
end

local function ignoreMessage(rare, reason)
	local message = rare.ID..", "
	if rare.Name then message = message..rare.Name..", " end
	if rare.EventType then message = message..rare.EventType..", " end
	if rare.Health then message = message..rare.Health..", " end
	if rare.X then message = message..rare.X..", " end
	if rare.Y then message = message..rare.Y..", " end
	if rare.SourceCharacter then message = message..rare.SourceCharacter..", " end
	if rare.SourcePublisher then message = message..rare.SourcePublisher..", " end

	log("Ignoring message: "..reason..": "..message)
end

function RareShare:RegisterSubscriber(sub, includeOutOfZoneEvents)
	if includeOutOfZoneEvents then
		unfilteredSubscribers[#unfilteredSubscribers + 1] = sub
	else
		filteredSubscribers[#filteredSubscribers + 1] = sub
	end
end

function RareShare:Publish(rare)
	-- TODO: Some cleaning up of data, eg. force ID to int, etc.

	local validationResults = RareShare:ValidateRare(rare)
	if validationResults ~= nil then
		ignoreMessage(rare, "Invalid rare! "..validationResults)
		return
	end

	-- Check that this message isn't older than one we already parsed
	-- We're allowing messages with the *same* time, simply because lua time() is to the second, and it's better to dupe than miss events
	if latestRareMessages[rare.ID] and latestRareMessages[rare.ID] > rare.Time then
		ignoreMessage(rare, "Out of date")
		return
	end

	-- Ignore unreliable health estimates that say 0 (RareCoordinator sends 0 when < 10%)
	if rare.HealthPriority and rare.HealthPriority > 1 and rare.Health == 0 then
		ignoreMessage(rare, "Bad health message (0)")
		return
	end

	-- Ignore unreliable health estimates if they're within the threshold (eg. don't overwrite a RareShare 25% with a RareCoorindator 20%, but do overwrite it with a RareCoorindator 10%)
	if rare.HealthPriority and rare.HealthPriority > 1 and knownRares[rare.ID] then
		-- If health priority is worse than previous
		if not knownRares[rare.ID].HealthPiority or knownRares[rare.ID].HealthPiority < rare.HealthPriority then
			if knownRares[rare.ID].Health - rare.Health < rare.HealthPriority then
				ignoreMessage(rare, "Bad health message")
				return
			end
		end
	end

	-- Don't re-broadcast events unless something has changed (X, Y, Zone, Health unless last event was more than x seconds ago)
	if knownRares[rare.ID] then
		local known = knownRares[rare.ID]
		if known.EventType == rare.EventType and known.X == rare.X and known.Y == rare.Y and known.Health == rare.Health and rare.Time < known.Time + 5 then
			ignoreMessage(rare, "Repeat message: "..rare.Time.." vs "..known.Time)
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
				log("Subscriber error: "..err)
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

function RareShare:GetKnownRaresForTesting()
	return knownRares
end

local function decayRares()
	local now = time()
	for _, rare in pairs(knownRares) do
		if rare.Time < now - 300 then -- Decay if last event was more than 5 mins ago (5 * 60 = 300 seconds)
			local decayMessage = {
				ID = rare.ID,
				EventType = "Decay",
				Time = time(),
				SourceCharacter = UnitName("player"),
				SourcePublisher = "RareShareDecay"
			}

			RareShare:Publish(decayMessage)
		end
	end
end

-- We want to periodically process old rares and "Decay" them (notify subscribers they're out-of-date, without marking them dead)
local timeTillDecay = 5.0
function onUpdate(self, elapsed)
	timeTillDecay = timeTillDecay - elapsed

	if timeTillDecay < 0 then
		timeTillDecay = 5.0

		decayRares()
	end
end

local frame = CreateFrame("MessageFrame", "RareShareTimer")
frame:SetScript("OnUpdate", onUpdate)

-- HACK: If author, enable boadcasting external events
local me = UnitName("player")
if me == "Shoomoo" or me == "Warmole" then
	RareShare:EnableAnnouncingOfExternalEvents()
end