SUBSYSTEM_DEF(nowhere)
	name = "Nowhere"
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 1 SECOND

	var/datum/nowhere_phase/current_state

	var/obj/effect/landmark/testmap_teleport_marker/fog_teleport

/datum/controller/subsystem/nowhere/Initialize(start_timeofday)
	. = ..()
	fog_teleport = locate(/obj/effect/landmark/testmap_teleport_marker/spawnloc) in GLOB.landmarks_list
	current_state = new /datum/nowhere_phase/six
	current_state.on_enter_state(TRUE)

/datum/controller/subsystem/nowhere/fire(resumed)
	if(!current_state.next_state)
		return

	if(floor(station_time() / (1 HOUR)) == current_state.next_state.hour)
		var/new_state = current_state.next_state
		current_state = new new_state
		current_state.on_enter_state(TRUE)

/datum/controller/subsystem/nowhere/proc/for_whom_the_bell_tolls(mob/living/user, cinematic = FALSE, time = station_time())
	user.playsound_local(get_turf(user), 'sound/effects/belltoll.ogg', 50, FALSE, pressure_affected = FALSE)

	if(cinematic)
		ADD_TRAIT(user, TRAIT_DEAF, "eternity_cinematic")
		ADD_TRAIT(user, TRAIT_KNOCKEDOUT, "eternity_cinematic")

		user.overlay_fullscreen("eternity_entry", /atom/movable/screen/fullscreen/blind/blinder/above_hud)

	var/list/screen_texts = list()

	var/station_time_as_text = time_to_twelve_hour(time, "hh:mm", TRUE)
	var/hours_to_midnight = round((24 HOURS - time) / (1 HOUR), 1)

	if(hours_to_midnight != 0)
		screen_texts += user.play_screen_text(station_time_as_text, /atom/movable/screen/text/screen_text/bell_toll)
	else
		screen_texts += user.play_screen_text("The Dark Star rises", /atom/movable/screen/text/screen_text/bell_toll)

	sleep(5.7 SECONDS)

	if(hours_to_midnight != 0)
		screen_texts += user.play_screen_text("[hours_to_midnight] Hours to Midnight", /atom/movable/screen/text/screen_text/bell_toll/countdown)
	else
		screen_texts += user.play_screen_text("in Carcosa", /atom/movable/screen/text/screen_text/bell_toll/countdown)

	sleep(5.8 SECONDS)
	if(hours_to_midnight == 0)
		screen_texts += user.play_screen_text("OVERTHROW THE KING", /atom/movable/screen/text/screen_text/bell_toll/subtext)

	sleep(5.7 SECONDS)

	if(cinematic)
		REMOVE_TRAIT(user, TRAIT_KNOCKEDOUT, "eternity_cinematic")
		REMOVE_TRAIT(user, TRAIT_DEAF, "eternity_cinematic")

		user.clear_fullscreen("eternity_entry", 3 SECONDS)

	for(var/atom/movable/screen/text/screen_text/text in screen_texts)
		text.fade_out()

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
	var/selected_type = tgui_input_list(src, "Select state", "Nowhere State Selector", subtypesof(/datum/nowhere_phase))
	if(!selected_type)
		return

	SSnowhere.current_state = new selected_type
	SSnowhere.current_state.on_enter_state()

/mob/verb/rotatestate()
	var/list/paths = subtypesof(/datum/nowhere_phase)
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

/datum/nowhere_phase
	var/hour
	var/datum/nowhere_phase/next_state
	var/area_color
	var/area_alpha

	var/list/areas_lit = list(
		/area/outdoors,
		/area/outdoors/carcosa,
		/area/station/testmap/home/outdoor_light,
	)

/datum/nowhere_phase/proc/on_enter_state(bing_bong)
	SHOULD_CALL_PARENT(TRUE)
	for(var/area_type in areas_lit)
		var/area/outdoors/area = GLOB.areas_by_type[area_type]
		area.set_base_lighting(area_color, area_alpha)

	if(bing_bong)
		bing_bong()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NOWHERE_PHASE_CHANGE, src)

/datum/nowhere_phase/proc/bing_bong()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue

		SSnowhere.for_whom_the_bell_tolls(player, FALSE, hour HOURS)

/datum/nowhere_phase/six
	next_state = /datum/nowhere_phase/seven
	hour = 18
	area_color = /area/outdoors::base_lighting_color
	area_alpha = /area/outdoors::base_lighting_alpha

/datum/nowhere_phase/seven
	next_state = /datum/nowhere_phase/eight
	hour = 19
	area_color = "#dfac72"
	area_alpha = 240

/datum/nowhere_phase/eight
	next_state = /datum/nowhere_phase/nine
	hour = 20
	area_color = "#dfac72"
	area_alpha = 200

/datum/nowhere_phase/nine
	next_state = /datum/nowhere_phase/ten
	hour = 21
	area_color = "#df9a72"
	area_alpha = 150

/datum/nowhere_phase/ten
	next_state = /datum/nowhere_phase/eleven
	hour = 22
	area_color = "#ccecff"
	area_alpha = 50

/datum/nowhere_phase/eleven
	next_state = /datum/nowhere_phase/midnight
	hour = 23
	area_color = "#ccecff"
	area_alpha = 10

/datum/nowhere_phase/eleven/on_enter_state()
	. = ..()
	var/obj/effect/landmark/kiy_book/book_spawn = locate() in GLOB.landmarks_list
	new /obj/item/kinginyellow(get_turf(book_spawn))

/datum/nowhere_phase/midnight
	hour = 0
	area_color = "#800080"
	area_alpha = 50

/datum/nowhere_phase/midnight/bing_bong()
	SSnowhere.fog_teleport = locate(/obj/effect/landmark/testmap_teleport_marker/tower_of_babel) in GLOB.landmarks_list
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue

		// If they read the stupid book.
		player.remove_status_effect(/datum/status_effect/grouped/king_in_yellow)

		player.forceMove(SSnowhere.fog_teleport.get_teleport_location())
		SSnowhere.for_whom_the_bell_tolls(player, TRUE, 24 HOURS)
