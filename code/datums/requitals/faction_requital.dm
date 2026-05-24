/// Belongs to an entire faction, can exist alongside normal requitals. Rolled after normal ones.
/datum/requital/faction
	abstract_type = /datum/requital/faction

	conflict_flags = REQUITAL_CONFLICT_FACTION

	/// Whitelist
	var/list/faction_whitelist = list()
	/// Blacklist.
	var/list/faction_blacklist = list(
		/datum/job_department/silicon,
		/datum/job_department/undefined,
	)

	/// A reference to the job department chosen.
	var/datum/job_department/chosen_faction

/datum/requital/faction/is_valid_initial_owner(datum/mind/M)
	. = ..()
	if(!.)
		return

	if(length(faction_whitelist) && !(M.assigned_role.departments_list[1] in faction_whitelist))
		return FALSE

	if(length(faction_blacklist) && (M.assigned_role.departments_list[1] in faction_blacklist))
		return FALSE

	return TRUE

/datum/requital/faction/get_valid_targets(datum/requital_data/data, list/override_list)
	. = ..()
	. -= data.minds_by_faction[owners[1].assigned_role.departments_list[1]]

/datum/requital/faction/get_valid_owners(datum/requital_data/data, list/override_list)
	. = ..(data, data.minds_by_faction[owners[1].assigned_role.departments_list[1]])

/datum/requital/faction/finalize()
	. = ..()
	chosen_faction = SSjob.get_department_type(owners[1].assigned_role.departments_list[1])

/datum/requital/faction/debt
	faction_whitelist = list(
		/datum/job_department/cargo,
		/datum/job_department/medical,
	)

/datum/requital/faction/debt/get_target_text(datum/mind/target)
	return "I owe <b>[chosen_faction.employer_type.name] a large debt, they are unlikely to service me."

/datum/requital/faction/debt/get_owner_text(datum/mind/owner)
	return parse_text("%TARGET% [length(targets) > 1 ? "have" : "has"] been unable to pay us too many times, we should deny him further service until remedied.")

// Left the faction on poor terms.
/datum/requital/faction/defector
	faction_whitelist = list(
		/datum/job_department/medical,
		/datum/job_department/engineering,
		/datum/job_department/security,
		/datum/job_department/command
	)

	max_instances = 2

	var/list/owners_text_map = list(
		/datum/job_department/medical = "%TARGET% left the Society and denounced us, let us avoid wasting time on them if we can help it.",
		/datum/job_department/engineering = "%TARGET% was previously fired from the team after a grotesque accident, and we won't let them forget it.",
		/datum/job_department/security = "%TARGET% WAS DISHONORABLY DISCHARGED FOR THEIR BEHAVIOR! MAKE THEIR LIFE HELL!",
		/datum/job_department/command = "%TARGET% defected from the Remnant citing \"operational disagreements\". They must be some kind of terrorist or spy."
	)
	var/list/target_text_map = list(
		/datum/job_department/medical = "I'm known to have left and denounced the Aether Society, they may treat me differently.",
		/datum/job_department/engineering = "I was fired from Daedalus Industries after a horrible accident, I should lay low around them.",
		/datum/job_department/security = "I was \"dishonorably discharged\" from the M.P.C, and now they're here? Great!",
		/datum/job_department/command = "I fled the Federation Remnant years ago, and now they've come back to haunt me.",
	)

/datum/requital/faction/defector/get_target_text(datum/mind/target)
	return parse_text(target_text_map[chosen_faction.type])

/datum/requital/faction/defector/get_owner_text(datum/mind/owner)
	return parse_text(owners_text_map[chosen_faction.type])
