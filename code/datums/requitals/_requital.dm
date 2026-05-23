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

	var/owner_goal = rand(min_owners, max_owners)
	filter_owning_jobs(minds)

	for(var/datum/mind/M in minds)
		if(length(M.owned_requitals))
			continue

		owners += M

		if(length(owners) == owner_goal || length(owners) == max_owners)
			break

	if(length(owners) < min_owners)
		return FALSE

	return TRUE

/// Given a list of minds, trims it down based on the job filters.
/datum/requital/proc/filter_owning_jobs(list/minds)
	for(var/datum/mind/M in minds)
		if(length(owning_job_whitelist) && !(M.assigned_role in owning_job_whitelist))
			minds -= M
			continue

		if(length(owning_job_blacklist) && (M.assigned_role in owning_job_blacklist))
			minds -= M
			continue

	return minds

/// Given a list of minds, trims it down based on the job filters.
/datum/requital/proc/filter_target_jobs(list/minds)
	for(var/datum/mind/M in minds)
		if(length(target_job_whitelist) && !(M.assigned_role in target_job_whitelist))
			minds -= M
			continue

		if(length(target_job_blacklist) && (M.assigned_role in target_job_blacklist))
			minds -= M
			continue

	return minds

/datum/requital/proc/select_owners_from_faction(list/minds, datum/job_department/faction_type)
	PROTECTED_PROC(TRUE)

	if(!faction_type)
		return FALSE

	filter_owning_jobs(minds)

	for(var/datum/mind/other_mind as anything in minds)
		if(!(faction_type in other_mind.assigned_role.departments_list))
			continue

		owners += other_mind

	return length(owners)

/// Selects target(s), returns FALSE on failure.
/datum/requital/proc/select_targets(list/minds)
	PROTECTED_PROC(TRUE)

	var/target_goal = rand(min_targets, max_targets)
	filter_target_jobs(minds)

	for(var/datum/mind/M in minds)
		var/mind_has_conflicts = FALSE
		// Check to see if we are creating a reciprocal requital (ie, oweing eachother a debt)
		for(var/datum/requital/owned_requital as anything in M.owned_requitals)
			if(owned_requital.type == type)
				if(owners & owned_requital.targets) // They have a requital of this type targeting one of our owners.
					mind_has_conflicts = TRUE
				break

		if(mind_has_conflicts)
			continue

		// Check to see if they are already being targetted by a similar requital.
		for(var/datum/requital/other_requital as anything in M.targeted_requitals)
			if(other_requital.conflict_flags & conflict_flags)
				mind_has_conflicts = TRUE
				break

		if(mind_has_conflicts)
			continue

		targets += M
		if(length(targets) == target_goal || length(targets) == max_targets)
			break

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
