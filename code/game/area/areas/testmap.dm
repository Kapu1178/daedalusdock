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
