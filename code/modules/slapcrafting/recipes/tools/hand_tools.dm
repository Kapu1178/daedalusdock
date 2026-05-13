/datum/slapcraft_recipe/improvised_pickaxe
	name = "improvised_pickaxe"
	examine_hint = "You could craft a makeshift pickaxe with a crowbar and a knife."
	category = SLAP_CAT_TOOLS
	steps = list(
		/datum/slapcraft_step/item/crowbar,
		/datum/slapcraft_step/item/metal_knife,
		/datum/slapcraft_step/tool/welder/weld_together
	)
	result_type = /obj/item/pickaxe/improvised
