/datum/round_event_control/radiation_storm
	name = "Radiation Storm"
	typepath = /datum/round_event/radiation_storm
	max_occurrences = 0

/datum/round_event/radiation_storm


/datum/round_event/radiation_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen = 1

/datum/round_event/radiation_storm/announce(fake)
	priority_announce("High levels of radiation have been detected. Please report to the medical bay if any strange symptoms occur.", sound_type = ANNOUNCER_RADIATION)

/datum/round_event/radiation_storm/start()
	SSweather.run_weather(/datum/weather/rad_storm)
