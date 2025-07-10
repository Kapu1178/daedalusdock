/mob/living/simple_animal/trader/flock
	name = "Flocktrader Sa.le"
	desc = "Some sort of weird holographic image on some fancy totem thing. Seems like it wants to trade."

/mob/living/simple_animal/trader/flock/setup_dialogue()
	. = ..()

	dialogue_holder.set_root_node(new /datum/dialogue_node/flocktrader_greet)

// Greeting node, randomly picks a greeting
/datum/dialogue_node/flocktrader_greet
	child_nodes = list(
		/datum/dialogue_node,
		/datum/dialogue_node,
		/datum/dialogue_node/test,
	)

/datum/dialogue_node/flocktrader_greet/get_node_text()
	var/list/options = list(
		"Greetings, we are a permutation of the Signal, long live the Monarch. Would you like to engage in the exchange of matter?",
	)
	return "You hear a click come from your radio. <i>[FLOCKTEXT(pick(options))]</i>"

/datum/dialogue_node/test
	child_nodes = list(
		/datum/dialogue_node
	)
