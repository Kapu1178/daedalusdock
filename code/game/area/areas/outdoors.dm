/area/outdoors
	name = "Nowhere"
	icon_state = "space"

	requires_power = TRUE
	always_unpowered = TRUE

	area_lighting = AREA_LIGHTING_STATIC
	base_lighting_alpha = 240
	base_lighting_color = LIGHTBULB_COLOR_WARM

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	area_flags = UNIQUE_AREA | NO_ALERTS
	outdoors = TRUE

	ambience_index = null
	sound_environment = SOUND_ENVIRONMENT_PLAIN

/area/outdoors/on_joining_game(mob/living/boarder)
	. = ..()
	SSnowhere.enter_the_crossroads(boarder)

/area/outdoors/midnight
	base_lighting_alpha = 80
	base_lighting_color = COLOR_PURPLE

/obj/effect/mob_container
	name = ""

/obj/effect/mob_container/examine(mob/user)
	return vis_contents[1]:examine(user)
