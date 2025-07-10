/datum/dialogue_node
	/// The dialogue holder this node belongs to.
	var/datum/dialogue_holder/holder
	/// The node that is a direct parent to this one.
	var/datum/dialogue_node/parent_node

	/// ID assigned by the holder for look-ups.
	var/id = ""

	/// The NPC text for this node. Use get_node_text()
	var/node_text = "You shouldn't see this, as this is debug text!"

	/// Dialogue options, effectively. Use get_child_nodes().
	var/list/datum/dialogue_node/child_nodes

/datum/dialogue_node/New(datum/dialogue_holder/_holder, datum/dialogue_node/_parent_node)
	..()
	holder = _holder
	parent_node = _parent_node

	for(var/node_path as anything in child_nodes)
		child_nodes -= node_path
		add_child_node_of_type(node_path)

/datum/dialogue_node/Destroy(force, ...)
	holder = null
	parent_node = null
	return ..()

/// Returns the text
/datum/dialogue_node/proc/get_node_text()
	return node_text

/// Returns the child nodes available.
/datum/dialogue_node/proc/get_child_nodes()
	return child_nodes

/// Adds a new child node of the given type.
/datum/dialogue_node/proc/add_child_node_of_type(datum/dialogue_node/new_node_type)
	child_nodes += new new_node_type(holder, src)
	return new_node_type
