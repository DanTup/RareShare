local function DumpRareToChat(rare)
	local flags = ""
	if rare.SuppressAnnouncements then flags = flags.." (noannounce)" end
	if rare.MajorEvent then flags = flags.." (major)" end
	if rare.EventType == "Alive" then
		print("RareShare Debug: "..rare.ID.." ("..rare.Name..") alive ("..rare.Health.."% HP) at ("..rare.X..","..rare.Y..") in "..rare.Zone..flags)
	elseif rare.EventType == "Dead" then
		print("RareShare Debug: "..rare.ID.." dead in "..rare.Zone..flags)
	end
end

if RareShare:IsDebugMode() then
	RareShare:RegisterSubscriber(DumpRareToChat)
end