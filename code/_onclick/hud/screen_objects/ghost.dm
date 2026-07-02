/atom/movable/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'
	private_screen = FALSE

/atom/movable/screen/ghost/MouseEntered(location, control, params)
	. = ..()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"
	screen_loc = ui_ghost_orbit

/atom/movable/screen/ghost/orbit/Click()
	. = ..()
	if(.)
		return FALSE
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"
	screen_loc = ui_ghost_reenter_corpse

/atom/movable/screen/ghost/reenter_corpse/Click()
	. = ..()
	if(.)
		return FALSE
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"
	screen_loc = ui_ghost_teleport

/atom/movable/screen/ghost/teleport/Click()
	. = ..()
	if(.)
		return FALSE

	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/pai
	name = "pAI Candidate"
	icon_state = "pai"
	screen_loc = ui_ghost_pai

/atom/movable/screen/ghost/pai/Click()
	. = ..()
	if(.)
		return FALSE

	var/mob/dead/observer/G = usr
	G.register_pai()
