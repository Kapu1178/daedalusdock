// I don't know if this is a good idea :)
/mob/living/simple_animal/trader
	name = "Trader"

	// Simple animal shit
	wander = FALSE
	stop_automated_movement = TRUE

	/// The container for dialogue tree behavior.
	var/tmp/datum/dialogue_holder/dialogue_holder

/mob/living/simple_animal/trader/Initialize(mapload)
	. = ..()
	setup_dialogue()

/mob/living/simple_animal/trader/Destroy()
	QDEL_NULL(dialogue_holder)
	return ..()

/// Initialize the dialogue holder and set up it's tree.
/mob/living/simple_animal/trader/proc/setup_dialogue()
	dialogue_holder = new /datum/dialogue_holder(src)


