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

// /datum/requital/basic/dodging_payment

// 	owning_job_whitelist = list(
// 		JOB_ACOLYTE,
// 		JOB_AUGUR,
// 		JOB_DECKHAND,
// 		JOB_QUARTERMASTER,
// 	)
