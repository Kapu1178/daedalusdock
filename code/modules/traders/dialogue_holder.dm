/datum/dialogue_holder
	/// The NPC this holder belongs to.
	var/mob/living/simple_animal/trader/pawn

	/// The very first thing you see when you open the UI.
	var/datum/dialogue_node/root_node

	/// The current node of conversation.
	var/datum/dialogue_node/current_node

	/// All nodes by their UUID.
	var/list/nodes_by_id

/datum/dialogue_holder/New(mob/living/simple_animal/trader/trader)
	..()
	pawn = trader

/datum/dialogue_holder/Destroy()
	pawn = null
	current_node = null
	nodes_by_id = null
	root_node = null
	QDEL_LIST_ASSOC_VAL(nodes_by_id)
	return ..()

/// Setter for the root node that then generates the node list.
/datum/dialogue_holder/proc/set_root_node(new_node)
	root_node = new_node
	setup_tree()

/// Sets up the dialogue tree and gives every node an ID for easy lookup.
/datum/dialogue_holder/proc/setup_tree()
	nodes_by_id = list()
	depth_first_search(root_node)

/// Build the node ID table.
/datum/dialogue_holder/proc/depth_first_search(datum/dialogue_node/searching, list/visited_nodes = list(), id_number = 1)
	visited_nodes[searching] = TRUE
	nodes_by_id["node[id_number]"] = searching
	searching.id = "node[id_number]"

	for(var/datum/dialogue_node/child_node as anything in searching.child_nodes)
		if(visited_nodes[child_node])
			continue

		depth_first_search(child_node, visited_nodes, ++id_number)
