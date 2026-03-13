SUBSYSTEM_DEF(nowhere)
	name = "Nowhere"
	flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 1 SECOND

	var/datum/nowhere_state/current_state

/datum/controller/subsystem/nowhere/fire(resumed)
	return

/datum/controller/subsystem/nowhere/proc/for_whom_the_bell_tolls(mob/living/user, cinematic = FALSE, time = station_time())
	user.playsound_local(get_turf(user), 'sound/effects/belltoll.ogg', 50, FALSE, pressure_affected = FALSE)

	if(cinematic)
		ADD_TRAIT(user, TRAIT_KNOCKEDOUT, "eternity_cinematic")
		ADD_TRAIT(user, TRAIT_DEAF, "eternity_cinematic")

		user.overlay_fullscreen("eternity_entry", /atom/movable/screen/fullscreen/blind/blinder/above_hud)

	var/station_time = time
	var/station_time_as_text = time_to_twelve_hour(station_time, "hh:mm", TRUE)
	var/atom/movable/screen/text/screen_text/time_text = user.play_screen_text(station_time_as_text, /atom/movable/screen/text/screen_text/bell_toll)

	sleep(5.7 SECONDS)

	var/hours_to_midnight = round((24 HOURS - station_time) / (1 HOUR), 1)
	var/atom/movable/screen/text/screen_text/countdown_text = user.play_screen_text("[hours_to_midnight] Hours to Midnight", /atom/movable/screen/text/screen_text/bell_toll/countdown)

	sleep(11.5 SECONDS) // Ends two bell tolls later.

	if(cinematic)
		REMOVE_TRAIT(user, TRAIT_KNOCKEDOUT, "eternity_cinematic")
		REMOVE_TRAIT(user, TRAIT_DEAF, "eternity_cinematic")

		user.clear_fullscreen("eternity_entry", 3 SECONDS)
		time_text.fade_out()
		countdown_text.fade_out()

	return TRUE

/datum/controller/subsystem/nowhere/proc/enter_the_crossroads(mob/living/memory, time = station_time())
	set waitfor = FALSE

	var/obj/effect/mob_container/container = new(get_turf(memory))
	memory.forceMove(container)
	container.add_viscontents(memory)

	memory.add_filter("join_blur", 1, gauss_blur_filter(10))
	memory.transition_filter("join_blur", 10 SECONDS, list("size" = 0))

	container.alpha = 0
	animate(container, alpha = 255, time = 10 SECONDS)

	for_whom_the_bell_tolls(memory, TRUE, time)
	memory.remove_filter("join_blur")

	memory.forceMove(get_turf(container))
	qdel(container)

/mob/verb/teststate()
	var/selected_type = tgui_input_list(src, "Select state", "Nowhere State Selector", subtypesof(/datum/nowhere_state))
	if(!selected_type)
		return

	SSnowhere.current_state = new selected_type
	SSnowhere.current_state.on_enter_state()

/mob/verb/rotatestate()
	var/list/paths = subtypesof(/datum/nowhere_state)
	var/static/rotating = FALSE
	if(rotating)
		rotating = FALSE
		return

	rotating = TRUE
	while(rotating)
		var/selected_type = paths[1]
		paths -= selected_type
		paths += selected_type

		SSnowhere.current_state = new selected_type
		SSnowhere.current_state.on_enter_state()
		sleep(5 SECONDS)

/datum/nowhere_state
	var/area_color
	var/area_alpha

	var/list/areas_lit = list(
		/area/outdoors,
		/area/station/testmap/home/outdoor_light,
	)

/datum/nowhere_state/proc/on_enter_state()
	SHOULD_CALL_PARENT(TRUE)
	for(var/area_type in areas_lit)
		var/area/outdoors/area = GLOB.areas_by_type[area_type]
		area.set_base_lighting(area_color, area_alpha)

/datum/nowhere_state/seven
	area_color = "#dfac72"
	area_alpha = 240

/datum/nowhere_state/eight
	area_color = "#dfac72"
	area_alpha = 200

/datum/nowhere_state/nine
	area_color = "#df9a72"
	area_alpha = 150

/datum/nowhere_state/ten
	area_color = "#ccecff"
	area_alpha = 50

/datum/nowhere_state/eleven
	area_color = "#ccecff"
	area_alpha = 10

/datum/nowhere_state/midnight
	area_color = "#800080"
	area_alpha = 50

/datum/nowhere_state/midnight/on_enter_state()
	..()

	var/obj/effect/landmark/king_landmark = locate() in GLOB.landmarks_list
	new /obj/effect/fakemob/king(king_landmark.loc)
