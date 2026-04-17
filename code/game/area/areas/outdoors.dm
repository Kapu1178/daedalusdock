/area/outdoors
	name = "Nowhere"
	icon_state = "space"

	requires_power = TRUE
	always_unpowered = TRUE

	area_lighting = AREA_LIGHTING_STATIC
	base_lighting_color = LIGHTBULB_COLOR_SLIGHTLY_WARM
	base_lighting_alpha = 240

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	area_flags = UNIQUE_AREA | NO_ALERTS
	outdoors = TRUE

	ambientsounds = list(
		'sound/ambience/ambiruin2.ogg',
		'sound/ambience/ambiruin4.ogg',
		'sound/ambience/ambiruin7.ogg',
		'sound/ambience/ambiodd.ogg',
		'sound/ambience/ambimystery.ogg',
	)
	ambient_buzz = 'sound/ambience/wind.ogg'
	ambient_buzz_vol = 100
	min_ambience_cooldown = 2 MINUTES
	max_ambience_cooldown = 6 MINUTES

	sound_environment = SOUND_ENVIRONMENT_PLAIN

/area/outdoors/on_joining_game(mob/living/boarder)
	. = ..()
	// The retarded second arg is to account for CHECK_TICK affecting the actual spawn times by a handful of seconds, amplified by the map's timescale.
	//(station_time() in (18 HOURS) to (18 HOURS + 5 MINUTES)) ? 18 HOURS : station_time()
	SSnowhere.enter_the_crossroads(boarder, SSticker.round_start_time ? station_time() : 18 HOURS)

/area/outdoors/has_ambient_buzz()
	return TRUE

/area/outdoors/midnight
	base_lighting_alpha = /datum/nowhere_phase/midnight::area_alpha
	base_lighting_color = /datum/nowhere_phase/midnight::area_color

/obj/effect/mob_container
	name = ""

/obj/effect/mob_container/examine(mob/user)
	return vis_contents[1]:examine(user)

/area/outdoors/carcosa
	name = "Carcosa"
