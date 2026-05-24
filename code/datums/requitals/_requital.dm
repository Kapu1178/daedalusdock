/datum/requital
	abstract_type = /datum/requital

	var/desc = "ERROR"

	/// Flags to what conflicts with what.
	var/conflict_flags = REQUITAL_CONFLICT_GENERAL
	/// Job types that can get this requital as an owner. Takes priority over owning_job_blacklist.
	var/list/owning_job_whitelist = list()
	/// Job types that cannot own this requital.
	var/list/owning_job_blacklist = list(/datum/job/ai)

	/// Job types that can be targetted by this requital. Takes priority over target_job_blacklist.
	var/list/target_job_whitelist = list()
	/// Job types that cannot be targetted by this requital.
	var/list/target_job_blacklist = list(/datum/job/ai)

	/// Minimum number of owners.
	var/min_owners = 1
	/// Maximum number of owners.
	var/max_owners = 1

	/// Minimum number of targets.
	var/min_targets = 1
	/// Minimum number of owners.
	var/max_targets = 1

	/// The weight for this requital to roll relative to the others. Default 100.
	var/weight = 100

	/// The maximum number of times this requital can roll.
	var/max_instances = 1

	/// List of minds that own this.
	var/list/datum/mind/owners = list()
	/// List of minds that are targeted by this.
	var/list/datum/mind/targets = list()

/datum/requital/Destroy(force, ...)
	for(var/datum/mind/M in owners)
		LAZYREMOVE(M.owned_requitals, src)

	for(var/datum/mind/M in targets)
		LAZYREMOVE(M.targeted_requitals, src)

	owners = null
	targets = null
	. = ..()

/// Setup the requital. Returns FALSE if it is unable to find owners or targets that meet it's criteria.
/datum/requital/proc/setup(datum/requital_data/data, datum/mind/initial_owner)
	if(!select_owners(data, initial_owner))
		return FALSE

	if(!select_targets(data))
		return FALSE

	finalize(data)
	return TRUE

/// Selects owner(s), returns FALSE on failure.
/datum/requital/proc/select_owners(datum/requital_data/data, datum/mind/initial_owner)
	PROTECTED_PROC(TRUE)

	owners += initial_owner
	var/owner_goal = rand(min_owners, max_owners)

	if(length(owners) == owner_goal)
		return TRUE

	var/list/potential_owners = get_valid_owners(data) - initial_owner
	for(var/datum/mind/M in potential_owners)
		owners += M

		if(length(owners) == owner_goal)
			break

	if(length(owners) < min_owners)
		return FALSE

	return TRUE

/// Returns a list of valid owners.
/datum/requital/proc/get_valid_owners(datum/requital_data/data, list/override_list) as /list
	if(length(owning_job_whitelist))
		var/real_list = override_list || data.minds_by_job
		. = flatten_list(real_list & owning_job_whitelist)

	else if (length(owning_job_blacklist))
		var/real_list = override_list || data.minds_by_job
		. = flatten_list(real_list - owning_job_blacklist)

	else
		. = override_list?.Copy() || data.all_minds.Copy()

	. -= data.is_owner

/// Should we even bother trying...
/datum/requital/proc/is_valid_initial_owner(datum/mind/M)
	if(length(owning_job_whitelist) && (!(M.assigned_role.type in owning_job_whitelist)))
		return FALSE

	else if(length(owning_job_whitelist) && (M.assigned_role.type in owning_job_blacklist))
		return FALSE

	return TRUE

/// Returns all valid targets in a list. The list is a copy and mutable.
/datum/requital/proc/get_valid_targets(datum/requital_data/data, list/override_list)
	if(length(target_job_whitelist))
		var/real_list = override_list || data.minds_by_job
		. = flatten_list(real_list & target_job_whitelist)

	else if (length(target_job_blacklist))
		var/real_list = override_list || data.minds_by_job
		. = flatten_list(real_list - target_job_blacklist)

	else
		. = override_list?.Copy() || data.all_minds.Copy()

	. -= data.is_target
	. -= owners

	for(var/datum/mind/M in .)
		for(var/datum/requital/owned_requital as anything in M.owned_requitals)
			// Check to see if we are creating a reciprocal requital (ie, oweing eachother a debt)
			if(owned_requital.type == type && (owners & owned_requital.targets)) // They have a requital of this type targeting one of our owners.
				. -= M

/// Selects target(s), returns FALSE on failure.
/datum/requital/proc/select_targets(datum/requital_data/data)
	PROTECTED_PROC(TRUE)

	var/target_goal = rand(min_targets, max_targets)

	var/list/potential_targets = get_valid_targets(data)
	for(var/datum/mind/M in potential_targets)
		targets += M

		if(length(targets) == target_goal)
			break

	if(length(targets) < min_targets)
		return FALSE

	return TRUE

/// This requital is ready to go.
/datum/requital/proc/finalize(datum/requital_data/data)
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/mind/M in owners)
		LAZYADD(M.owned_requitals, src)
		data.is_owner[M] = src

	for(var/datum/mind/M in targets)
		LAZYADD(M.targeted_requitals, src)
		data.is_target[M] = src

	message_admins("[english_list(owners)] [length(owners) > 1 ? "were" : "was"] granted [type] targeting [english_list(targets)]")

/// Just read the proc dude.
/datum/requital/proc/parse_text(text)
	var/list/owner_names = list()
	var/list/target_names = list()

	for(var/datum/mind/M as anything in owners)
		owner_names += M.name

	for(var/datum/mind/M as anything in targets)
		target_names += M.name

	var/owner_names_text = "<b>[english_list(owner_names)]</b>"
	var/target_names_text = "<b>[english_list(target_names)]</b>"

	text = replacetext_char(text, "%TARGET%", target_names_text)
	text = replacetext_char(text, "%OWNER%", owner_names_text)
	return text

/// Returns the string to display to a target.
/datum/requital/proc/get_owner_text(datum/mind/owner)
	return ""

/// Returns the string to display to a target.
/datum/requital/proc/get_target_text(datum/mind/target)
	return ""


/datum/requital_data
	var/list/all_minds

	/// Minds by department type
	var/list/minds_by_faction = list()
	/// Minds by job type
	var/list/minds_by_job = list()

	/// LUT of minds that own a requital already, to that requital.
	var/list/is_owner = list()

	/// LUT of minds that are already a target, to that requital.
	var/list/is_target = list()

/datum/requital_data/New(list/minds)
	all_minds = shuffle(minds)

	minds_by_faction = list()
	minds_by_job = list()

	for(var/datum/mind/M as anything in all_minds)
		LAZYADD(minds_by_job[M.assigned_role.type], M)

		var/faction = length(M.assigned_role.departments_list) && M.assigned_role.departments_list[1]
		LAZYADD(minds_by_faction[faction], M)
