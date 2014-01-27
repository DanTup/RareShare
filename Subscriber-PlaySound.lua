local function PlaySound(rare)
	-- Never do anything if disabled
	if not RareShare:AllowSounds() then return end

	if rare.EventType == "Alive" and rare.MajorEvent then
		PlaySoundFile("sound\\CREATURE\\MANDOKIR\\VO_ZG2_MANDOKIR_LEVELUP_EVENT_01.ogg", "master")		
	end
end

RareShare:RegisterSubscriber(PlaySound)
