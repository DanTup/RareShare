RareShare v1.3
===
- Fixed a number of functions to no longer have global names, such that they conflicted with other addons/Blizzard functions, causing other addons/frames to not work correctly

RareShare v1.2
===
- Added an option to suppress Evermaw events when 100% health, toggled with '/rs evermaw', enabled by default

RareShare v1.1
===
- Added a command '/rs' to list status of RareShare options
- Added an option to toggle announcing of rares in chat, toggled with '/rs announce'
- Added an option to toggle playing sounds upon discovering a rare, toggled with '/rs sounds'
- Added an option to toggle creation of TomTom waypoints, toggled with '/rs tomtom'
- All RareShare options persist across logins/reloads and are shared across all characters


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
