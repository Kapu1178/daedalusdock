/mob/dead/ghost
	name = "Ghost"

	/// Prefixed adjective to the ghost's name
	var/ghost_adjective = ""
	/// name = "[ghost_adjective] [ghost_term] of [real_name]"
	var/ghost_term = ""

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

/mob/dead/ghost/update_name(updates)
	. = ..()
	deadchat_name = name

/mob/dead/ghost/get_visible_name()
	return "[ghost_adjective] [ghost_term] of [real_name]"

/mob/dead/ghost/canUseTopic(atom/movable/target, flags)
	return FALSE
