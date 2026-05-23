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

/datum/requital/faction/select_owners(list/minds)
	for(var/datum/mind/mind as anything in minds)
		if(!length(mind.assigned_role.departments_list))
			continue

		if(locate(/datum/requital/faction) in mind.owned_requitals)
			continue

		var/datum/job_department/mind_faction = mind.assigned_role.departments_list[1]
		if(mind_faction.is_not_real_department)
			continue

		if(length(faction_whitelist) && !(mind_faction in faction_whitelist))
			continue

		if(length(faction_blacklist) && (mind_faction in faction_blacklist))
			continue

		chosen_faction = SSjob.get_department_type(mind_faction)
		break

	return select_owners_from_faction(minds, chosen_faction?.type)

/datum/requital/faction/debt
	appearance_chance = 100
	faction_whitelist = list(
		/datum/job_department/cargo,
		/datum/job_department/medical,
	)

/datum/requital/faction/debt/get_target_text(datum/mind/target)
	return "I owe <b>[chosen_faction.employer_type.name] a large debt, they are unlikely to service me."

/datum/requital/faction/debt/get_owner_text(datum/mind/owner)
	return parse_text("%TARGET% [length(targets) > 1 ? "have" : "has"] been unable to pay us too many times, we should deny him further service until remedied.")
