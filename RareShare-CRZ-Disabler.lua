-- Currently (5.4) there is no way to tell which servers zone you are in when you're
-- grouped with someonethat is not from your realm (or a connected realm). This means
-- there's no way to tell if the messages being recieved apply to your zone or not.
-- Until Blizzard give some sort of API for this (so we can transmit an "instance ID"
-- in messages), we have to just disable RareShare while in a group that contains
-- someone that's not from your group of servers (LE_REALM_RELATION_COALESCED).
-- Note: Virtual/Connected realms should work fine, since they share a zone.

local function checkForCRZ()
	local prefix = IsInRaid() and "raid" or "party"

	local isPossiblyCoalesced = false
	for i = 0, GetNumGroupMembers() do
		print(prefix..i)
		if UnitRealmRelationship(prefix..i) == LE_REALM_RELATION_COALESCED then
			isPossiblyCoalesced = true
			break
		end
	end

	RareShare:SetIsCrz(isPossiblyCoalesced)
end

local frame = CreateFrame("MessageFrame", "RareShareCRZDisabler")
frame:SetScript("OnEvent", checkForCRZ)
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
