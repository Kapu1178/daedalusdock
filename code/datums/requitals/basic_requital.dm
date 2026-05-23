/// Basic requitals have a single target string and single owner string that get run through a parse function to add names.
/datum/requital/basic
	abstract_type = /datum/requital/basic

	var/base_target_string
	var/base_owner_string

	var/cached_target_string
	var/cached_owner_string

/datum/requital/basic/get_owner_text(datum/mind/owner)
	return cached_owner_string ||= parse_text(base_owner_string)

/datum/requital/basic/get_target_text(datum/mind/target)
	return cached_target_string ||= parse_text(base_target_string)

// Someone owes someone else a favor. Easy.
/datum/requital/basic/favor
	appearance_chance = 100

	appearance_max = 5

	base_target_string = "I owe %OWNER% a favor for helping me out in the past."
	base_owner_string = "%TARGET% owes me a favor for helping them out in the past."

// This is like the faction debt one but for the indies.
/datum/requital/basic/dodging_payment
	appearance_chance = 80

	owning_job_whitelist = list(
		/datum/job/botanist,
		/datum/job/bartender,
		/datum/job/cook
	)

	target_job_blacklist = list(
		/datum/job/botanist,
		/datum/job/bartender,
		/datum/job/cook,
		/datum/job/ai,
	)

	base_target_string = "I have a delinquent tab at %OWNER%'s place, I need to pay it off before they'll serve me again."
	base_owner_string = "%TARGET% has built up a massive tab and isn't paying, I'm not serving him."

// I bribed a cop!
/datum/requital/basic/bribe
	appearance_chance = 75

	owning_job_blacklist = list(
		/datum/job/security_officer,
		/datum/job/head_of_security,
		/datum/job/warden,
		/datum/job/captain,
		/datum/job/head_of_personnel
	)

	target_job_whitelist = list(
		/datum/job/security_officer,
		/datum/job/head_of_security,
		/datum/job/warden,
	)

	base_target_string = "%OWNER% paid me a pretty penny to look the other way once before."
	base_owner_string = "I bribed %TARGET% to turn a blind eye to me once before, it might work again."

// Someone got promoted when you totally deserved it!
/datum/requital/basic/rival
	appearance_chance = 20

	owning_job_whitelist = list(
		/datum/job/security_officer,
		/datum/job/station_engineer,
		/datum/job/cargo_technician,
	)

	base_owner_string = "%TARGET% was promoted instead of me, despite my far superior skills!"
	base_target_string = "I was promoted instead of %OWNER%, they might be pissed."

/datum/requital/basic/rival/filter_target_jobs(list/minds)
	// Limits the target pool to just people in our faction.
	var/our_faction = owners[1].assigned_role.departments_list[1]
	for(var/datum/mind/M as anything in minds)
		if(!(our_faction in M.assigned_role.departments_list))
			minds -= M
	. = ..()

