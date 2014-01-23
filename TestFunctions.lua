RareShareTests = {}

function RareShareTests:ResetEnvironment()
	RareShare:ResetState()
	RareShare:EnableDebugMode()
	currentZone = "Timeless Isle"
end

currentZone = "Timeless Isle"
function RareShareTests:SetZone(zone)
	currentZone = zone
end

function RareShareTests:BroadcastChat(channel, sender, message)
	local channelSubscribers = RareShare:GetChannelSubscribersForTesting()
	for chan, subs in pairs(channelSubscribers) do
		if chan == channel then
			for _, sub in pairs(subs) do
				sub(sender, message)
			end
		end
	end
end





-- WoW Stubs
function GetZoneText()
	return currentZone
end

function time()
	return os.time()
end

function CreateFrame()
	return {
		SetScript = function() end,
		RegisterEvent = function() end,
	}
end




-- Helper Functions

function assert_eq(x, y, m)
	if x == nil and y == nil then return end
	if m == nil then m = "" end
	if x ~= nil and y == nil then
		error("Assert fail: "..x.." ~= nil : "..m)
	end
	if y ~= nil and x == nil then
		error("Assert fail: nil ~= "..y.." : "..m)
	end
	if x ~= y then
		error("Assert fail: "..x.." ~= "..y.." : "..m)
	end
end

function assert_tables_eq(t1, t2)
	for k, v in pairs(t1) do
		assert_eq(t1[k], t2[k], k)
	end
	for k, v in pairs(t2) do
		assert_eq(t1[k], t2[k], k)
	end
end
