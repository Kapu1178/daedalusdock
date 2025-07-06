/obj/effect/flock_fluff
	icon = 'goon/icons/mob/featherzone.dmi'
	density = TRUE

// /obj/effect/flock_fluff/shuttleRotate(rotation, params)
// 	params &= ~ROTATE_DIR
// 	..()
// 	transform = matrix().Turn(rotation)

/obj/effect/flock_fluff/cockpit
	icon = 'goon/icons/mob/featherzone-160x160.dmi'
	icon_state = "shuttle-nose"
	pixel_x = -64
	pixel_y = -64

	name = "shuttle cockpit"
	dir = WEST

/obj/effect/flock_fluff/shuttle_wing
	icon = 'goon/icons/mob/featherzone-96x96.dmi'

/obj/effect/flock_fluff/shuttle_wing/setDir(ndir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -32
			pixel_y = 32
		if(SOUTH)
			pixel_x = -32
			pixel_y = -96
		if(EAST)
			pixel_x = 32
			pixel_y = -32
		if(WEST)
			pixel_x = -96
			pixel_y = -32

/obj/effect/flock_fluff/shuttle_wing/shuttleRotate(rotation, params = ROTATE_DIR)
	params &= ~ROTATE_OFFSET
	. = ..()

/obj/effect/flock_fluff/shuttle_wing/left
	icon_state = "wing_left"

/obj/effect/flock_fluff/shuttle_wing/right
	icon_state = "wing_right"

/obj/effect/flock_fluff/shuttle_wing/broken
	icon_state = "wing-broken"

/obj/effect/flock_fluff/shuttle_wing/destroyed
	icon_state = "wing-destroyed"
