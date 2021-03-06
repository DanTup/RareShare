﻿local names = {}
names[73174] = "Archiereus of Flame (Sanctuary)"
names[73666] = "Archiereus of Flame (Summoned)"
names[72775] = "Bufo"
names[73171] = "Champion of the Black Flame"
names[72045] = "Chelon"
names[73175] = "Cinderfall"
names[72049] = "Cranegnasher"
names[73281] = "Dread Ship Vazuvius"
names[73158] = "Emerald Gander"
names[73279] = "Evermaw"
names[73172] = "Flintlord Gairan"
names[73282] = "Garnia"
names[72970] = "Golganarr"
names[73161] = "Great Turtle Furyshell"
names[72909] = "Gu'chi the Swarmbringer"
names[73167] = "Huolon"
names[73163] = "Imperial Python"
names[73160] = "Ironfur Steelhorn"
names[73169] = "Jakur of Ordon"
names[72193] = "Karkanos"
names[73277] = "Leafmender"
names[73166] = "Monstrous Spineclaw"
names[72048] = "Rattleskew"
names[73157] = "Rock Moss"
names[71864] = "Spelurk"
names[72769] = "Spirit of Jadefire"
names[73704] = "Stinkbraid"
names[72808] = "Tsavo'ka"
names[73173] = "Urdur the Cauterizer"
names[73170] = "Watcher Osu"
names[72245] = "Zesqua"
names[71919] = "Zhu-Gon the Sour"


local function handleMessage(sender, rcMessage)
	local parts = RareShare:StringSplit(rcMessage, "[^_]+")
	if #parts ~= 4 then
		if RareShare:IsDebugMode() then
			print("Unexpected RareCoordinator message: "..rcMessage)
		end
		return
	end

	local rare = { Zone = "Timeless Isle", SourceCharacter = sender, SourcePublisher = "RareCoordinator" }
	rare.ID = RareShare:ToInt(parts[2])
	rare.Time = RareShare:ToInt(parts[4])
	rare.Name = names[rare.ID]

	if rare.Name == nil then
		if RareShare:IsDebugMode() then
			print("RC Rare not known; bailing")
		end
		return
	end

	local rcEventType = parts[3]
	if rcEventType == "dead" then
		rare.EventType = "Dead"
	elseif RareShare:StringStarts(rcEventType, "alive") then
		rare.EventType = "Alive"
		local loc = RareShare:StringSplit(rcEventType, "[^,%-]+")
		if #loc == 3 then
			rare.X = RareShare:ToInt(loc[2])
			rare.Y = RareShare:ToInt(loc[3])
		else
			return -- No location, old version of RC; so just ignore
		end
		
		rare.Health = tonumber(string.sub(loc[1], 6))
		rare.HealthPriority = 10
	else
		return -- Unknown event type
	end

	rare.AllowAnnouncing = RareShare:AllowAnnouncingOfExternalEvents()

	RareShare:Publish(rare)
end

RareShare:SubscribeToChat("RCELVA", handleMessage)
