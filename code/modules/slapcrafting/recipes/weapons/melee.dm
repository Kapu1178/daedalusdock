//Spears
/datum/slapcraft_recipe/spear
	name = "makeshift spear"
	examine_hint = "You could craft a makeshift spear with a wirerod and a shard of glass."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/wirerod,
		/datum/slapcraft_step/item/glass_shard/insert //this is for different glass types
	)
	result_type = /obj/item/spear

/datum/slapcraft_recipe/explosive_lance
	name = "explosive lance"
	examine_hint = "You could attach a grenade to a spear."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/spear,
		/datum/slapcraft_step/item/grenade,
		/datum/slapcraft_step/stack/or_other/binding
	)
	result_type = /obj/item/spear/explosive

/datum/slapcraft_step/spear
	desc = "Start with a spear."
	item_types = list(/obj/item/spear)

/datum/slapcraft_recipe/explosive_lance/create_item(item_path, obj/item/slapcraft_assembly/assembly)
	var/obj/item/spear/explosive/spear = new item_path(assembly.drop_location())
	var/obj/item/grenade/G = locate() in assembly
	spear.set_explosive(G)
	return spear


//Stunprods
/datum/slapcraft_recipe/stunprod
	name = "stunprod"
	examine_hint = "You could craft a cattleprod with a wirerod and an igniter."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/wirerod,
		/datum/slapcraft_step/item/igniter
	)
	result_type = /obj/item/melee/baton/security/cattleprod


//shivs
/datum/slapcraft_recipe/glass_shiv
	name = "glass shiv"
	examine_hint = "You could add some cloth to a shard of glass to make a shiv."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/item/glass_shard/insert, //this is for different glass types
		/datum/slapcraft_step/stack/or_other/shiv_wrap

	)
	result_type = /obj/item/knife/shiv

/datum/slapcraft_step/stack/or_other/shiv_wrap
	desc = "Wrap some cloth or tape around the base."
	todo_desc = "You could use some cloth or tape to hold the shard without cutting your hand..."
	item_types = list(
		/obj/item/stack/sticky_tape,
		/obj/item/stack/sheet/cloth
	)
	amounts = list(
		/obj/item/stack/sticky_tape = 3,
		/obj/item/stack/sheet/cloth = 1,
	)

//misc. weapons
/datum/slapcraft_recipe/mace
	name = "iron mace"
	examine_hint = "You could craft a crude bludgeon with a rod and a metal ball."
	category = SLAP_CAT_WEAPONS
	steps = list(
		/datum/slapcraft_step/stack/rod/one,
		/datum/slapcraft_step/item/metal_ball,
		/datum/slapcraft_step/tool/welder/weld_together
	)
	result_type = /obj/item/mace
