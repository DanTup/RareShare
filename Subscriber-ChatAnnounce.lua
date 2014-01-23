local function AnnounceInChat(rare)
	if rare.MajorEvent then
		if rare.EventType == "Alive" then
			SendChatMessage("(RareShare) "..rare.Name.." spotted around "..rare.X..","..rare.Y.." with "..rare.Health.." HP!", "GUILD")
		elseif rare.EventType == "Dead" then
			SendChatMessage("(RareShare) "..rare.Name.." has been killed!", "GUILD")
		end
	end
end

RareShare:RegisterSubscriber(AnnounceInChat)
