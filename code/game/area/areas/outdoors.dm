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
	spawn(-1)
		var/obj/effect/mob_container/container = new(get_turf(boarder))
		boarder.forceMove(container)
		container.add_viscontents(boarder)

		boarder.add_filter("join_blur", 1, gauss_blur_filter(10))
		boarder.transition_filter("join_blur", 10 SECONDS, list("size" = 0))

		container.alpha = 0
		animate(container, alpha = 255, time = 10 SECONDS)

		SSeternity.for_whom_the_bell_tolls(boarder, TRUE)
		boarder.remove_filter("join_blur")

		boarder.forceMove(get_turf(container))
		qdel(container)

/area/outdoors/midnight
	base_lighting_alpha = 80
	base_lighting_color = COLOR_PURPLE

/obj/effect/mob_container
	name = ""

/obj/effect/mob_container/examine(mob/user)
	return vis_contents[1]:examine(user)

/mob/verb/bells()
	var/mob/living/boarder = src
	var/obj/effect/mob_container/container = new(get_turf(boarder))

	boarder.forceMove(container)
	container.add_viscontents(boarder)

	boarder.add_filter("join_blur", 1, gauss_blur_filter(10))
	boarder.transition_filter("join_blur", 10 SECONDS, list("size" = 0))

	container.alpha = 0
	animate(container, alpha = 255, time = 10 SECONDS)

	SSeternity.for_whom_the_bell_tolls(boarder, TRUE)
	boarder.remove_filter("join_blur")

	boarder.forceMove(get_turf(container))
	qdel(container)
