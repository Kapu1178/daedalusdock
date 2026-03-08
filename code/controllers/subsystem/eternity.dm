SUBSYSTEM_DEF(eternity)
	name = "Eternity"
	flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME
	wait = 1 SECOND

/datum/controller/subsystem/eternity/fire(resumed)
	. = ..()

/datum/controller/subsystem/eternity/proc/for_whom_the_bell_tolls(mob/living/user, cinematic = FALSE)
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

