/datum/status_effect/eternity
	id = "eternityshadow"
	duration = -1
	tick_interval = 1 SECOND

	alert_type = null

	var/seconds_spent = 0

/datum/status_effect/eternity/on_apply()
	. = ..()
	owner.add_filter("eternity_shadower", 1, color_matrix_filter(rgb(0, 0, 0)))
	owner.add_filter("eternity_gaussian_blur", 1, gauss_blur_filter(2))
	owner.add_filter("eternity_motion_blur", 1, motion_blur_filter(0 , 0))
	ADD_TRAIT(owner, TRAIT_NO_SPRINT, "eternity")
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_move))

	to_chat(owner, span_warning("A chill washes over your body as you step into the mist."))

/datum/status_effect/eternity/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.remove_filter(list("eternity_shadower", "eternity_gaussian_blur", "eternity_motion_blur"))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/eternity)
	REMOVE_TRAIT(owner, TRAIT_NO_SPRINT, "eternity")

/datum/status_effect/eternity/tick(delta_time, times_fired)
	. = ..()

	seconds_spent++
	if(seconds_spent <= 10 && (seconds_spent % 2 == 0))
		owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/eternity, slowdown = 1 + (seconds_spent * 0.8))
		owner.transition_filter(
		"eternity_motion_blur", 2 SECONDS,
			list(
				"y" = 1 + floor(seconds_spent / 2),
				"x" = 1 + floor(seconds_spent / 2)
			)
		)

	if(seconds_spent == 10)
		fade_away(owner)

/datum/status_effect/eternity/proc/fade_away(mob/living/memory)
	set waitfor = FALSE

	memory.notransform = TRUE
	memory.transition_filter(
	"eternity_motion_blur", 2 SECONDS,
		list(
			"y" = 15,
			"x" = 15,
		)
	)
	animate(memory, time = 2 SECONDS, alpha = 0, transform = owner.transform.Scale(0, 3))

	sleep(2 SECONDS)

	memory.alpha = initial(memory.alpha)
	memory.notransform = FALSE
	memory.transform = matrix()
	memory.remove_filter("eternity_motion_blur")

	get_start_landmark_for(/obj/effect/landmark/start/backup::name).get_spawn_location().JoinPlayerHere(memory)
	SSnowhere.enter_the_crossroads(memory)

/datum/status_effect/eternity/proc/on_owner_move()
	SIGNAL_HANDLER

	if(!istype(get_turf(owner), /turf/open/indestructible/eternity))
		qdel(src)
