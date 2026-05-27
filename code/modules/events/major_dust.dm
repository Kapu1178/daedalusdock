/datum/round_event_control/meteor_wave/major_dust
	name = "Major Space Dust"
	typepath = /datum/round_event/meteor_wave/major_dust
	weight = 20

/datum/round_event/meteor_wave/major_dust
	wave_name = "space dust"

/datum/round_event/meteor_wave/major_dust/announce(fake)
	priority_announce(uppertext("Local debris field collapsing on the station vector, prepare for minor hull damage."), FLAVOR_DEFENSE_SYSTEM, sub_title = "Collision Alert", sound_type = ANNOUNCER_ALERT)
