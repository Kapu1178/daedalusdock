/datum/c4_file/user
	name = "user account"
	extension = "USR"
	size = 1

	/// Unique Identifier, for permissions
	var/uuid
	/// Login name, name on ID card.
	var/registered_name
	/// Job on ID card.
	var/assignment
	/// Access o- okay you get the idea.
	var/list/access

	/// Permission groups
	var/list/permission_groups

/datum/c4_file/user/New()
	..()
	generate_uuid()

/// Generate a unique identifier
/datum/c4_file/user/proc/generate_uuid()
	var/list/nums = list()
	for(var/i in 1 to 3)
		nums += trunc(rand() * 256)

	uuid = jointext(nums, "")

/datum/c4_file/user/copy()
	var/datum/c4_file/user/clone = ..()
	clone.uuid = uuid
	clone.registered_name = registered_name
	clone.assignment = assignment
	clone.access = access.Copy()
	clone.permission_groups = permission_groups.Copy()
	return clone
