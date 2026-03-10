SUBSYSTEM_DEF(nowhere)
	name = "Nowhere"
	flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 1 SECOND

/datum/controller/subsystem/nowhere/fire(resumed)
	return

/datum/controller/subsystem/nowhere/proc/for_whom_the_bell_tolls(mob/living/user, cinematic = FALSE)
	user.playsound_local(get_turf(user), 'sound/effects/belltoll.ogg', 50, FALSE, pressure_affected = FALSE)

	if(cinematic)
		ADD_TRAIT(user, TRAIT_KNOCKEDOUT, "eternity_cinematic")
		ADD_TRAIT(user, TRAIT_DEAF, "eternity_cinematic")

		user.overlay_fullscreen("eternity_entry", /atom/movable/screen/fullscreen/blind/blinder/above_hud)

	var/atom/movable/screen/text/screen_text/time_text = user.play_screen_text("[time_to_twelve_hour(station_time(), "hh:mm")]", /atom/movable/screen/text/screen_text/bell_toll)

	sleep(5.7 SECONDS)

	var/hours_to_midnight = round((24 HOURS - station_time()) / (1 HOUR), 1)
	var/atom/movable/screen/text/screen_text/countdown_text = user.play_screen_text("[hours_to_midnight] Hours to Midnight", /atom/movable/screen/text/screen_text/bell_toll/countdown)

	sleep(11.5 SECONDS) // Ends two bell tolls later.

	if(cinematic)
		REMOVE_TRAIT(user, TRAIT_KNOCKEDOUT, "eternity_cinematic")
		REMOVE_TRAIT(user, TRAIT_DEAF, "eternity_cinematic")

		user.clear_fullscreen("eternity_entry", 3 SECONDS)
		time_text.fade_out()
		countdown_text.fade_out()

	return TRUE

/datum/controller/subsystem/nowhere/proc/enter_the_crossroads(mob/living/memory)
	set waitfor = FALSE

	var/obj/effect/mob_container/container = new(get_turf(memory))
	memory.forceMove(container)
	container.add_viscontents(memory)

	memory.add_filter("join_blur", 1, gauss_blur_filter(10))
	memory.transition_filter("join_blur", 10 SECONDS, list("size" = 0))

	container.alpha = 0
	animate(container, alpha = 255, time = 10 SECONDS)

	for_whom_the_bell_tolls(memory, TRUE)
	memory.remove_filter("join_blur")

	memory.forceMove(get_turf(container))
	qdel(container)

/datum/nowhere_state
	var/area_color
	var/area_alpha

/datum/nowhere_state/proc/on_enter_state()
	SHOULD_CALL_PARENT(TRUE)
	var/area/outdoors/area = GLOB.areas_by_type[/area/outdoors]
	area.set_base_lighting(area_color, 80)

/datum/nowhere_state/midnight
	area_color = COLOR_PURPLE
	area_alpha = 80

/datum/nowhere_state/midnight/on_enter_state()
	..()

	var/obj/effect/landmark/king_landmark = locate() in GLOB.landmarks_list
	new /obj/effect/fakemob/king(king_landmark.loc)
