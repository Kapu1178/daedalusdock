/// Playwright spawn location
/obj/effect/landmark/king
	icon = 'goon/icons/obj/kinginyellow.dmi'
	icon_state = "kingyellow"

/// Spawn location for the crown at the end of the round
/obj/effect/landmark/king_death

/// Marker for roundstart spawn turfs.
/obj/effect/landmark/start/backup/testmap
	var/obj/effect/landmark/testmap_teleport_marker/spawnloc/internal_marker

/obj/effect/landmark/start/backup/testmap/Initialize(mapload)
	. = ..()
	internal_marker = new(src)

/obj/effect/landmark/start/backup/testmap/get_spawn_location()
	return internal_marker.get_teleport_location()

/obj/effect/landmark/testmap_teleport_marker
	var/list/turfs
	var/range = 3

/obj/effect/landmark/testmap_teleport_marker/Initialize(mapload)
	. = ..()
	get_turfs()

/obj/effect/landmark/testmap_teleport_marker/proc/get_teleport_location()
	. = pick_n_take(turfs)
	if(!length(turfs))
		get_turfs()

/obj/effect/landmark/testmap_teleport_marker/proc/get_turfs()
	turfs = RANGE_TURFS(3, get_step(src, 0))

/obj/effect/landmark/testmap_teleport_marker/spawnloc // spawn is a reserved keyword

/obj/effect/landmark/testmap_teleport_marker/tower_of_babel

/obj/effect/landmark/kiy_book
	icon = /obj/item/kinginyellow::icon
	icon_state = /obj/item/kinginyellow::icon_state
