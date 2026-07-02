/mob/dead/ghost
	name = "Ghost"

	sight = NONE
	simulated = FALSE

	movement_delay = 4

	/// Prefixed adjective to the ghost's name
	var/ghost_adjective = ""
	/// name = "[ghost_adjective] [ghost_term] of [real_name]"
	var/ghost_term = ""

/mob/dead/ghost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE, 1, -6, TRUE)

/mob/dead/ghost/proc/from_corpse(mob/corpse)
	ghost_term = pick(GLOB.ghost_synonyms)
	ghost_adjective = pick(GLOB.fresh_ghost_adjectives)

	if(ismob(corpse))
		mind = corpse.mind //we don't transfer the mind but we keep a reference to it.
		set_suicide(corpse.suiciding) // Transfer whether they committed suicide.

		gender = corpse.gender
		died_as_name = corpse.died_as_name
		set_ghost_appearance(corpse)
		set_real_name(get_name_from_corpse(corpse))

/mob/dead/ghost/Move(atom/newloc, direct, glide_size_override, z_movement_flags)
	// Requires this hacky copy-pasting from client/Move() to get gliding to behave.
	//We are now going to move
	var/old_move_delay
	var/add_delay
	var/new_glide_size
	if(client)
		old_move_delay = client?.move_delay
		add_delay = movement_delay
		new_glide_size = DELAY_TO_GLIDE_SIZE(add_delay * ( (NSCOMPONENT(direct) && EWCOMPONENT(direct)) ? DIAGONAL_MOVEMENT_MULTIPLIER : 1 ) )

		set_glide_size(new_glide_size) // set it now in case of pulled objects
		if(old_move_delay + world.tick_lag > world.time)
			client.move_delay = old_move_delay
		else
			client.move_delay = world.time

		client.visual_delay = 0

	. = ..()
	if(client)
		if((direct & (direct - 1)) && loc == newloc) //moved diagonally successfully
			add_delay *= DIAGONAL_MOVEMENT_MULTIPLIER

		var/after_glide = 0
		if(client.visual_delay)
			after_glide = client.visual_delay
		else
			after_glide = DELAY_TO_GLIDE_SIZE(add_delay)

		set_glide_size(after_glide)

		client.move_delay += add_delay

/mob/dead/ghost/update_name(updates)
	. = ..()
	deadchat_name = name

/mob/dead/ghost/get_visible_name()
	return "[ghost_adjective] [ghost_term] of [real_name]"

/mob/dead/ghost/canUseTopic(atom/movable/target, flags)
	return FALSE
