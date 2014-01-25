RareShare v1.0
===
- Don't announce rares in chat if they're below 50% health to reduce volume of messages (it's unlikely people will get there in time anyway). This does not affect display of TomTom waypoints of sharing of data for these rares
- Added support for detecting rares by simply rolling your mouse over them, without having to explicitly target them


RareShare v0.10
===
- Fixed an issue with NPC ID calculation which would cause RareCoordinator and RareShare NPCs not to match up, resulting in some duplicate events


RareShare v0.9
===
- Fixed an issue that could cause duplicate events/notifications if an event was received via both RareShare and RareCoordinator channels


RareShare v0.8
===
- Detects targetting and health changes of rares
- Detects deaths of rares via combat log
- Announces discovery (and death) of rare mobs in General chat for people not using RareShare
- Plays a "ding!" upon discovery of a rare
- If the [TomTom](http://www.curse.com/addons/wow/tomtom) addon is found, creates a TomTom waypoint for any discovered rare, keeping the location up-to-date as the mob moves
- Displays the current HP of the rare in the TomTom waypoint for convenience
- Shares all data with other RareShare users
- Parses messages from the RareCoordinator addon
