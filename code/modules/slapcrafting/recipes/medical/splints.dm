/datum/slapcraft_recipe/makeshift_splint
	name = "Makeshift Splint"
	examine_hint = "You could craft a makeshift splint with some rods and a fixing."
	category = SLAP_CAT_MEDICAL
	steps = list(
		/datum/slapcraft_step/stack/or_other/binding,
		/datum/slapcraft_step/stack/rod/two,
	)
	result_type = /obj/item/stack/splint/makeshift
