/datum/requital
	abstract_type = /datum/requital

	var/desc = "ERROR"

	/// Job types that can get this requital as an owner. Takes priority over owning_job_blacklist.
	var/list/owning_job_whitelist = list()
	/// Job types that cannot own this requital.
	var/list/owning_job_blacklist = list(/datum/job/ai)

	/// Job types that can be targetted by this requital. Takes priority over target_job_blacklist.
	var/list/target_job_whitelist = list()
	/// Job types that cannot be targetted by this requital.
	var/list/target_job_blacklist = list(/datum/job/ai)

	/// If TRUE, grants this requital to the entire faction of the owner.
	var/entire_faction_owns = FALSE

	/// Minimum number of owners. entire_faction_owns ignores this.
	var/min_owners = 1
	/// Maximum number of owners. entire_faction_owns ignores this.
	var/max_owners = 1

	/// Minimum number of targets.
	var/min_targets = 1
	/// Minimum number of owners.
	var/max_targets = 1

	/// The chance for this requital to roll.
	var/appearance_chance = 20
	/// The maximum number of times this requital can roll.
	var/appearance_max = 1

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
/datum/requital/proc/setup(list/minds)
	if(!select_owners(minds))
		return FALSE

	if(!select_targets(minds - owners))
		return FALSE

	finalize()
	return TRUE

/// Selects owner(s), returns FALSE on failure.
/datum/requital/proc/select_owners(list/minds)
	PROTECTED_PROC(TRUE)

	while(length(minds) && length(owners) < max_owners)
		var/datum/mind/M = pick_n_take(minds)
		if(length(M.owned_requitals))
			continue

		if(length(owning_job_whitelist) && !(M.assigned_role in owning_job_whitelist))
			continue

		if(length(owning_job_blacklist) && (M.assigned_role in owning_job_blacklist))
			continue

		if(entire_faction_owns)
			var/datum/job_department/faction = length(M.assigned_role.departments_list) && M.assigned_role.departments_list[1]
			if(faction.is_not_real_department)
				continue

			owners += M
			select_owners_from_faction(minds, faction)
			break

		owners += M

	if(length(owners) < min_owners)
		return FALSE

	return TRUE

/// Callke
/datum/requital/proc/select_owners_from_faction(list/minds, datum/job_department/faction_type)
	PROTECTED_PROC(TRUE)

	for(var/datum/mind/other_mind as anything in minds)
		if(!(faction_type in other_mind.assigned_role.departments_list))
			continue

		if(length(owning_job_whitelist) && !(other_mind.assigned_role in owning_job_whitelist))
			continue

		if(length(owning_job_blacklist) && (other_mind.assigned_role in owning_job_blacklist))
			continue

		owners += other_mind

/// Selects target(s), returns FALSE on failure.
/datum/requital/proc/select_targets(list/minds)
	PROTECTED_PROC(TRUE)

	while(length(minds) && length(targets) < max_targets)
		var/datum/mind/M = pick_n_take(minds)
		if(length(M.targeted_requitals))
			continue

		if(length(target_job_whitelist) && !(M.assigned_role in target_job_whitelist))
			continue

		if(length(target_job_blacklist) && (M.assigned_role in target_job_blacklist))
			continue

		targets += M

	if(length(targets) < min_targets)
		return FALSE

	return TRUE

/// This requital is ready to go.
/datum/requital/proc/finalize()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/mind/M in owners)
		LAZYADD(M.owned_requitals, src)

	for(var/datum/mind/M in targets)
		LAZYADD(M.targeted_requitals, src)

/// Returns the string to display to a target.
/datum/requital/proc/get_owner_text(datum/mind/owner)
	return ""

/// Returns the string to display to a target.
/datum/requital/proc/get_target_text(datum/mind/target)
	return ""
