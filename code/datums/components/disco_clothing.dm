/// A component for hooking COMSIG_DISCO_FLAVOR on items when they are equipped to a mob. Arguments are taken from /mob/proc/disco_made_easy.
/datum/component/disco_clothing
	var/id
	var/requirement
	var/skill_path
	var/modifier
	var/is_examine
	var/success_text
	var/crit_success_text
	var/failure_text
	var/crit_failure_text
	var/trait_succeed
	var/trait_fail

/datum/component/disco_clothing/Initialize(
	id,
	requirement = 14,
	skill_path = /datum/rpg_skill/fourteen_eyes,
	modifier,
	success_text,
	crit_success_text,
	failure_text,
	crit_failure_text,
	trait_succeed,
	trait_fail
)
	. = ..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	src.id = id
	src.requirement = requirement
	src.skill_path = skill_path
	src.modifier = modifier
	src.success_text = success_text
	src.crit_success_text = crit_success_text
	src.failure_text = failure_text
	src.crit_failure_text = crit_failure_text
	src.trait_succeed = trait_succeed
	src.trait_fail = trait_succeed

	var/static/list/loc_connections = list(
		COMSIG_DISCO_FLAVOR = PROC_REF(on_parent_loc_disco)
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/disco_clothing/proc/on_parent_loc_disco(datum/source, mob/user, is_nearby, is_station_level)
	SIGNAL_HANDLER
	if(astype(parent, /obj/item).equipped_to != source)
		return

	if(astype(source, /mob).get_slot_by_item(parent) == ITEM_SLOT_HANDS)
		return

	user.disco_made_easy(id, requirement, skill_path, modifier, FALSE, success_text, crit_success_text, failure_text, crit_failure_text, trait_succeed, trait_fail)
