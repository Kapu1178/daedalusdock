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

/area/station/testmap/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	astype(arrived, /mob)?.add_client_colour(/datum/client_colour/monochrome/tower_of_babel)

/area/station/testmap/Exited(atom/movable/gone, direction)
	. = ..()
	astype(gone, /mob)?.remove_client_colour(/datum/client_colour/monochrome/tower_of_babel)
