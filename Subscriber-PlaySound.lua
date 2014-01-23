local function PlaySound(rare)
	if rare.EventType == "Alive" and rare.MajorEvent then
		PlaySoundFile("sound\\CREATURE\\MANDOKIR\\VO_ZG2_MANDOKIR_LEVELUP_EVENT_01.ogg", "master")		
	end
end

RareShare:RegisterSubscriber(PlaySound)
