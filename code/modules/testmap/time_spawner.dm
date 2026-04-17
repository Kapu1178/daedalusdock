/obj/effect/landmark/time_spawner
	var/hour = 18
	var/type_to_spawn

/obj/effect/landmark/time_spawner/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_NOWHERE_PHASE_CHANGE, PROC_REF(on_state_change))

/obj/effect/landmark/time_spawner/proc/on_state_change(datum/source, datum/nowhere_phase/new_phase)
	SIGNAL_HANDLER

	if(new_phase.hour == hour)
		spawn_things()

/obj/effect/landmark/time_spawner/proc/spawn_things()
	set waitfor = FALSE
	return new type_to_spawn(get_turf(src))

/obj/effect/landmark/time_spawner/npc
	icon = /obj/effect/landmark/start/backup::icon
	icon_state = /obj/effect/landmark/start/backup::icon_state

/obj/effect/landmark/time_spawner/npc/spawn_things()
	var/obj/effect/fakemob/fakemob = ..()
	var/obj/effect/mob_container/container = new(get_turf(fakemob))
	fakemob.forceMove(container)
	container.add_viscontents(fakemob)

	fakemob.add_filter("join_blur", 1, gauss_blur_filter(10))
	fakemob.transition_filter("join_blur", 10 SECONDS, list("size" = 0))

	container.alpha = 0
	animate(container, alpha = 255, time = 10 SECONDS)
	sleep(10 SECONDS)
	fakemob.remove_filter("join_blur")

/obj/effect/landmark/time_spawner/npc/holly
	type_to_spawn = /obj/effect/fakemob/holly

/obj/effect/landmark/time_spawner/npc/roadman
	type_to_spawn = /obj/effect/fakemob/roadman

/obj/effect/landmark/time_spawner/npc/stairman
	type_to_spawn = /obj/effect/fakemob/stairman

/obj/effect/landmark/time_spawner/npc/mistwalker
	type_to_spawn = /obj/effect/fakemob/mistwalker

/obj/effect/landmark/time_spawner/npc/scarecrow
	type_to_spawn = /obj/effect/fakemob/scarecrow
