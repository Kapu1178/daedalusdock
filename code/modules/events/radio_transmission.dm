/datum/round_event_control/radio_transmission
	name = "Radio Transmission"
	typepath = /datum/round_event/radio_transmission

	earliest_start = 5 MINUTES
	max_occurrences = 1

	alert_observers = FALSE

/datum/round_event/radio_transmission
	fakeable = FALSE

/datum/round_event/radio_transmission/announce(fake)
	var/list/announcements = list(
		"This is a heartbeat signal. If you receive this message, please respond.",
		"FEDERATION ANNOUNCEMENT: ANY SURVIVORS ARE TO EVACUATE THE AREA IMMEDIATELY.",
		"VECTOR 431415 281044 1050284 LIGHTYEARS MAYDAY MAYDAY"
	)

	var/sound/sound = sound('goon/sounds/sleeper_agent_hello.ogg', volume = 10)
	priority_announce(Gibberish(pick(announcements), TRUE, rand(20, 50), decode = FALSE, encode = FALSE), "Long Range Sensor Array", override_sound = sound)
