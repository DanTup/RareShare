﻿local function DumpRareToChat(rare, prefix)
	local flags = ""
	if rare.SuppressAnnouncements then flags = flags.." (noannounce)" end
	if rare.MajorEvent then flags = flags.." (major)" end
	if rare.EventType == "Alive" then
		print("|cff9999ffRareShare Debug:|r "..prefix.."|cff999999 ("..rare.SourceCharacter.." @ "..rare.SourcePublisher..") "..rare.ID.." ("..rare.Name..") alive ("..rare.Health.."% HP) at ("..rare.X..","..rare.Y..") in "..rare.Zone..flags)
	elseif rare.EventType == "Dead" then
		print("|cff9999ffRareShare Debug:|r "..prefix.."|cff999999 ("..rare.SourceCharacter.." @ "..rare.SourcePublisher..") "..rare.ID.." dead in "..rare.Zone..flags)
	end
end

local function DumpRareToChatUnfiltered(rare)
	DumpRareToChat(rare, "|cffffff99GLOBAL|r")
end

local function DumpRareToChatFiltered(rare)
	DumpRareToChat(rare, "|cffff9999ZONE|r")
end

if RareShare:IsDebugMode() then
	RareShare:RegisterSubscriber(DumpRareToChatUnfiltered, true)
	RareShare:RegisterSubscriber(DumpRareToChatFiltered)
end