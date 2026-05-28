/datum/round_event_control/radio_transmission
	name = "Radio Transmission"

	earliest_start = 5 MINUTES
	max_occurrences = 2

	alert_observers = FALSE

/datum/round_event/radio_transmission
	fakeable = FALSE

/datum/round_event/radio_transmission/announce(fake)
