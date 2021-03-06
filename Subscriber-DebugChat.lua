﻿local function DumpRareToChat(rare, prefix)
	if not RareShare:IsDebugMode() then return end

	local flags = ""
	if rare.AllowAnnouncing then flags = flags.." (announce)" end
	if rare.MajorEvent then flags = flags.." (major)" end
	if rare.EventType == "Alive" then
		print("|cff9999ffRareShare Debug:|r "..prefix.."|cff999999 ("..rare.SourceCharacter.." @ "..rare.SourcePublisher..") "..rare.ID.." ("..rare.Name..") alive ("..rare.Health.."% HP) at ("..rare.X..","..rare.Y..") in "..rare.Zone.." (time: "..rare.Time..")"..flags)
	elseif rare.EventType == "Dead" then
		print("|cff9999ffRareShare Debug:|r "..prefix.."|cff999999 ("..rare.SourceCharacter.." @ "..rare.SourcePublisher..") "..rare.ID.." dead in "..rare.Zone.." (time: "..rare.Time..")"..flags)
	elseif rare.EventType == "Decay" then
		print("|cff9999ffRareShare Debug:|r "..prefix.."|cff999999 ("..rare.SourceCharacter.." @ "..rare.SourcePublisher..") "..rare.ID.." decayed "..rare.Zone.." (time: "..rare.Time..")"..flags)
	end
end

local function DumpRareToChatUnfiltered(rare)
	DumpRareToChat(rare, "|cffffff99GLOBAL|r")
end

local function DumpRareToChatFiltered(rare)
	DumpRareToChat(rare, "|cffff9999ZONE|r")
end

-- Enable these in source as required; otherwise the volume of events makes normal debug messages hard to monitor!
--RareShare:RegisterSubscriber(DumpRareToChatUnfiltered, true)
--RareShare:RegisterSubscriber(DumpRareToChatFiltered)
