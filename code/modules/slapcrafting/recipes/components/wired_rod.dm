/datum/slapcraft_recipe/wirerod
	name = "wired rod"
	examine_hint = "You could combine a rod and some cable."
	category = SLAP_CAT_COMPONENTS
	steps = list(
		/datum/slapcraft_step/stack/rod/one,
		/datum/slapcraft_step/stack/cable/ten
	)
	result_type = /obj/item/wirerod

/datum/slapcraft_recipe/wirerod_dissasemble
	name = "unwired rod"
	examine_hint = "You could cut the wire off with something sharp."
	category = SLAP_CAT_COMPONENTS
	steps = list(
		/datum/slapcraft_step/item/wirerod,
		/datum/slapcraft_step/attack/sharp,
	)
	result_list = list(
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil/ten
	)
