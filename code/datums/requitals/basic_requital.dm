/// Basic requitals have a single target string and single owner string that get run through a parse function to add names.
/datum/requital/basic
	abstract_type = /datum/requital/basic

	var/base_target_string
	var/base_owner_string

	var/cached_target_string
	var/cached_owner_string

/// Just read the proc dude.
/datum/requital/basic/proc/parse_text(text)
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

/datum/requital/basic/get_owner_text(datum/mind/owner)
	return cached_owner_string ||= parse_text(base_owner_string)

/datum/requital/basic/get_target_text(datum/mind/target)
	return cached_target_string ||= parse_text(base_target_string)

/datum/requital/basic/favor
	appearance_chance = 100

	base_target_string = "I owe %OWNER% a favor for helping me out in the past."
	base_owner_string = "%TARGET% owes me a favor for helping them out in the past."
