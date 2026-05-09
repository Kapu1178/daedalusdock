/area/station/testmap
	area_lighting = AREA_LIGHTING_STATIC
	base_lighting_color = LIGHTBULB_COLOR_SLIGHTLY_WARM
	base_lighting_alpha = 240

	requires_power = FALSE

	ambience_index = null
	ambient_buzz = null


/area/station/testmap/ward
	name = "\improper Ward"
	icon_state = "medbay"

/area/station/testmap/home
	name = "Home"

/area/station/testmap/home/outdoor_light
	base_lighting_color = /area/outdoors::base_lighting_color
	base_lighting_alpha = /area/outdoors::base_lighting_alpha

/area/station/testmap/tower_of_babel
	name = "Tower of Babel"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

	base_lighting_color = /area/outdoors/midnight::base_lighting_color
	base_lighting_alpha = /area/outdoors/midnight::base_lighting_alpha

	ambientsounds = list(
		'sound/ambience/ambiruin2.ogg',
		'sound/ambience/ambiruin4.ogg',
		'sound/ambience/ambiruin7.ogg',
		'sound/ambience/ambiodd.ogg',
		'sound/ambience/ambimystery.ogg',
	)
	ambient_buzz = 'sound/ambience/wind.ogg'
	ambient_buzz_vol = 60
	min_ambience_cooldown = 2 MINUTES
	max_ambience_cooldown = 6 MINUTES

	var/list/heard_entry_sound = list()

/area/station/testmap/tower_of_babel/has_ambient_buzz()
	return TRUE

/area/station/testmap/tower_of_babel/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	var/mob/M = arrived
	if(istype(M))
		M.add_client_colour(/datum/client_colour/monochrome/tower_of_babel)
		play_entry_sound(M)

/area/station/testmap/tower_of_babel/Exited(atom/movable/gone, direction)
	. = ..()
	var/mob/M = gone
	if(istype(M))
		M.remove_client_colour(/datum/client_colour/monochrome/tower_of_babel)


/area/station/testmap/tower_of_babel/proc/play_entry_sound(mob/M)
	set waitfor = FALSE
	if(heard_entry_sound[M.ckey])
		return

	sleep(Frand(0, 4 SECONDS))

	if(heard_entry_sound[M.ckey])
		return

	heard_entry_sound[M.ckey] = TRUE

	var/list/sounds = list(
		'goon/sounds/void/Void_Calls.ogg',
		'goon/sounds/void/Void_Screaming.ogg',
		'goon/sounds/void/Void_Wail.ogg',
		'goon/sounds/void/Void_Hisses.ogg',
	)
	M.playsound_local(get_turf(M), pick(sounds), 40, FALSE, channel = CHANNEL_VOID_SOUND)
