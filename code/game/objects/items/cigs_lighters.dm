//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHES
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/smoketime = 10 SECONDS
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	grind_results = list(/datum/reagent/phosphorus = 2)
	/// Whether this match has been lit.
	var/lit = FALSE
	/// Whether this match has burnt out.
	var/burnt = FALSE
	/// How long the match lasts in seconds

/obj/item/match/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/match/process(delta_time)
	smoketime -= delta_time * (1 SECONDS)
	if(smoketime <= 0)
		matchburnout()
	else
		open_flame(heat)

/obj/item/match/fire_act(exposed_temperature, exposed_volume, turf/adjacent)
	matchignite()

/obj/item/match/proc/matchignite()
	if(lit || burnt)
		return

	playsound(src, 'sound/items/match_strike.ogg', 15, TRUE)
	lit = TRUE
	icon_state = "match_lit"
	damtype = BURN
	force = 3
	hitsound = 'sound/items/welder.ogg'
	inhand_icon_state = "cigon"
	name = "lit [initial(name)]"
	desc = "A [initial(name)]. This one is lit."
	attack_verb_continuous = string_list(list("burns", "singes"))
	attack_verb_simple = string_list(list("burn", "singe"))
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/match/proc/matchburnout()
	if(!lit)
		return

	lit = FALSE
	burnt = TRUE
	damtype = BRUTE
	force = initial(force)
	icon_state = "match_burnt"
	inhand_icon_state = "cigoff"
	name = "burnt [initial(name)]"
	desc = "A [initial(name)]. This one has seen better days."
	attack_verb_continuous = string_list(list("flicks"))
	attack_verb_simple = string_list(list("flick"))
	STOP_PROCESSING(SSobj, src)

/obj/item/match/extinguish()
	matchburnout()

/obj/item/match/unequipped(mob/user)
	matchburnout()
	return ..()

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	. = ..()
	if(.)
		return

	if(lit && M.ignite_mob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")

/obj/item/match/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!lit)
		return NONE

	var/obj/item/clothing/mask/cigarette/to_light = help_light_cig(interacting_with)
	if(!to_light)
		return NONE

	if(to_light.lit)
		to_chat(user, span_warning("[interacting_with.p_their(TRUE)] [to_light.name] is already lit."))
		return ITEM_INTERACT_BLOCKING

	if(interacting_with == user)
		to_light.item_interaction(src, user)
	else
		to_light.light(span_notice("[user] holds [src] out for [interacting_with], and lights [interacting_with.p_their()] [to_light.name]."))
	return ITEM_INTERACT_SUCCESS

/// Finds a cigarette on another mob to help light.
/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/get_temperature()
	return lit * heat

TYPEINFO_DEF(/obj/item/match/firebrand)
	default_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT)

/obj/item/match/firebrand
	name = "firebrand"
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 40 SECONDS
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	heat = 1000
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION
	equip_delay_self = 0
	/// Whether this cigarette has been lit.
	var/lit = FALSE
	/// Whether this cigarette should start lit.
	var/starts_lit = FALSE
	// Note - these are in masks.dmi not in cigarette.dmi
	/// The icon state used when this is lit.
	var/icon_on = "cigon"
	/// The icon state used when this is extinguished.
	var/icon_off = "cigoff"
	/// The inhand icon state used when this is lit.
	var/inhand_icon_on = "cigon"
	/// The inhand icon state used when this is extinguished.
	var/inhand_icon_off = "cigoff"
	/// How long the cigarette lasts in seconds
	var/smoketime = 6 MINUTES
	/// How much time between drags of the cigarette.
	var/dragtime = 10 SECONDS
	/// The cooldown that prevents just huffing the entire cigarette at once.
	COOLDOWN_DECLARE(drag_cooldown)
	/// The cooldown that staggers smoke effects.
	COOLDOWN_DECLARE(smoke_cooldown)
	/// The type of cigarette butt spawned when this burns out.
	var/type_butt = /obj/item/cigbutt
	/// The capacity for chems this cigarette has.
	var/chem_volume = 30
	/// The reagents that this cigarette starts with.
	var/list/list_reagents = list(/datum/reagent/drug/nicotine = 15)
	/// Should we smoke all of the chems in the cig before it runs out. Splits each puff to take a portion of the overall chems so by the end you'll always have consumed all of the chems inside.
	var/smoke_all = FALSE
	/// How much damage this deals to the lungs per drag.
	var/lung_harm = 1


/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	if(starts_lit)
		light()
	AddComponent(/datum/component/knockoff, 90, list(BODY_ZONE_PRECISE_MOUTH), slot_flags) //90% to knock off when wearing a mask
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_MASK|ITEM_SLOT_HANDS)
	icon_state = icon_off
	inhand_icon_state = inhand_icon_off

/obj/item/clothing/mask/cigarette/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/cigarette/equipped(mob/M, slot)
	. = ..()
	if(slot != ITEM_SLOT_MASK)
		return

	add_trace_DNA(M.get_trace_dna())

/obj/item/clothing/mask/cigarette/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is huffing [src] as quickly as [user.p_they()] can! It looks like [user.p_theyre()] trying to give [user.p_them()]self cancer."))
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/cigarette/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(lit)
		return NONE

	var/lighting_text = tool.ignition_effect(src, user)
	if(!lighting_text)
		return NONE

	var/datum/gas_mixture/air = unsafe_return_air()
	if(!air || !air.hasGas(GAS_OXYGEN, 1)) //or oxygen on a tile to burn
		to_chat(user, span_notice("\The [src] won't light."))
		return ITEM_INTERACT_BLOCKING

	if(smoketime <= 0)
		to_chat(user, span_warning("There is nothing left to smoke."))
		light(lighting_text)
		return ITEM_INTERACT_BLOCKING

	light(lighting_text)
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/mask/cigarette/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isliving(interacting_with))
		return interact_with_mob(interacting_with, user, modifiers)

	if(lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
		return NONE

	if(!istype(interacting_with, /obj/item/reagent_containers/cup)) //you can dip cigarettes into beakers
		return NONE

	var/obj/item/reagent_containers/cup/glass = interacting_with

	if(glass.reagents.trans_to(src, chem_volume, transfered_by = user)) //if reagents were transfered, show the message
		to_chat(user, span_notice("You dip \the [src] into \the [glass]."))
		return ITEM_INTERACT_SUCCESS

	//if not, either the beaker was empty, or the cigarette was full
	else if(!glass.reagents.total_volume)
		to_chat(user, span_warning("[glass] is empty!"))
	else
		to_chat(user, span_warning("[src] is full!"))

	return ITEM_INTERACT_BLOCKING

/obj/item/clothing/mask/cigarette/proc/interact_with_mob(mob/living/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with.on_fire && !lit)
		light(span_notice("[user] lights [src] with [interacting_with]'s body."))
		return ITEM_INTERACT_SUCCESS

	if(lit && user == interacting_with)
		if(!user.has_mouth())
			return ITEM_INTERACT_BLOCKING

		if(user.is_mouth_covered())
			to_chat(user, span_warning("Your mouth is covered."))
			return ITEM_INTERACT_BLOCKING

		user.visible_message(span_notice("[user] takes a drag of their [name]."))
		playsound(user, 'sound/effects/inhale.ogg', 50, 0, -1)
		use_reagents(user, TRUE)
		return TRUE

	var/obj/item/clothing/mask/cigarette/to_light = help_light_cig(interacting_with)
	if(to_light)
		if(to_light.lit)
			to_chat(user, span_warning("[to_light] is already lit."))
			return ITEM_INTERACT_BLOCKING

		if(interacting_with == user)
			to_light.item_interaction(src, user)
		else
			to_light.light(span_notice("[user] holds [src] out for [interacting_with], and lights [interacting_with.p_their()] [to_light.name]."))
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/clothing/mask/cigarette/update_icon_state()
	. = ..()
	if(lit)
		icon_state = icon_on
		inhand_icon_state = inhand_icon_on
	else
		icon_state = icon_off
		inhand_icon_state = inhand_icon_off

/// Lights the cigarette with given flavor text.
/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return

	lit = TRUE

	if(!initialized)
		update_icon()
		return

	playsound(loc, 'sound/effects/cig_light.ogg', 100)
	attack_verb_continuous = string_list(list("burns", "singes"))
	attack_verb_simple = string_list(list("burn", "singe"))
	hitsound = 'sound/items/welder.ogg'
	damtype = BURN
	force = 4

	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start(src)
		qdel(src)
		return

	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
		e.start(src)
		qdel(src)
		return

	// allowing reagents to react after being lit
	reagents.flags &= ~(NO_REACT)
	reagents.handle_reactions()
	update_icon()
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)

	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.update_slots_for_item(src)

	AddComponent(/datum/component/smell, INTENSITY_STRONG, SCENT_PLUME, "nicotine", 5)
	COOLDOWN_START(src, smoke_cooldown, 20 SECONDS)
	new /obj/effect/temp_visual/cig_smoke(drop_location())

/obj/item/clothing/mask/cigarette/extinguish()
	if(!lit)
		return

	playsound(loc, 'sound/effects/cig_snuff.ogg', 100)
	attack_verb_continuous = null
	attack_verb_simple = null
	hitsound = null
	damtype = BRUTE
	force = 0
	STOP_PROCESSING(SSobj, src)
	reagents.flags |= NO_REACT
	lit = FALSE
	update_icon()

	if(equipped_to)
		to_chat(equipped_to, span_notice("Your [name] goes out."))
		equipped_to.update_worn_mask()
		equipped_to.update_held_items()

	qdel(GetComponent(/datum/component/smell))

/// Handles processing the reagents in the cigarette.
/obj/item/clothing/mask/cigarette/proc/use_reagents(mob/living/carbon/user, drag)
	if(!reagents.total_volume)
		return

	reagents.expose_temperature(heat, 0.05)

	if(!reagents.total_volume) //may have reacted and gone to 0 after expose_temperature
		return

	var/to_smoke = smoke_all ? (reagents.total_volume * (dragtime / smoketime)) : REAGENTS_METABOLISM
	if(!istype(user) || ((src != user.wear_mask) && !drag))
		reagents.remove_all(to_smoke)
		return

	reagents.expose(user, INJECT, min(to_smoke / reagents.total_volume, 1))
	if(!reagents.trans_to(user, to_smoke, methods = INJECT))
		reagents.remove_all(to_smoke)

	if(drag || COOLDOWN_FINISHED(src, smoke_cooldown))
		new /obj/effect/temp_visual/cig_smoke(drop_location())
		COOLDOWN_START(src, smoke_cooldown, 20 SECONDS)

/obj/item/clothing/mask/cigarette/process(delta_time)
	var/mob/living/user = isliving(loc) ? loc : null
	user?.ignite_mob()
	if(!reagents.has_reagent(/datum/reagent/oxygen)) //cigarettes need oxygen
		var/datum/gas_mixture/air = return_air()
		if(!air || !air.hasGas(GAS_OXYGEN, 1)) //or oxygen on a tile to burn
			extinguish()
			return

	smoketime -= delta_time * (1 SECONDS)
	if(smoketime <= 0)
		put_out(user)
		return

	open_flame(heat)

	if((reagents?.total_volume) && COOLDOWN_FINISHED(src, drag_cooldown))
		COOLDOWN_START(src, drag_cooldown, dragtime)
		use_reagents(user)

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		put_out(user, TRUE)
	return ..()

/obj/item/clothing/mask/cigarette/proc/put_out(mob/user, done_early = FALSE)
	var/atom/location = drop_location()
	if(done_early)
		user.visible_message(span_notice("[user] calmly drops and treads on \the [src], putting it out instantly."))
		new /obj/effect/decal/cleanable/ash(location)
	else if(user)
		to_chat(user, span_notice("Your [name] goes out."))

	playsound(loc, 'sound/effects/cig_snuff.ogg', 100)

	var/obj/item/cigbutt/butt = new type_butt(location)
	transfer_evidence_to(butt)
	qdel(src)

/obj/item/clothing/mask/cigarette/fire_act(exposed_temperature, exposed_volume, turf/adjacent)
	light()

/obj/item/clothing/mask/cigarette/get_temperature()
	return lit * heat


// Cigarette brands.
/obj/item/clothing/mask/cigarette/space_cigarette
	desc = "A Space brand cigarette that can be smoked anywhere."
	list_reagents = list(/datum/reagent/drug/nicotine = 9, /datum/reagent/oxygen = 9)
	smoketime = 4 MINUTES // space cigs have a shorter burn time than normal cigs
	smoke_all = TRUE // so that it doesn't runout of oxygen while being smoked in space

/obj/item/clothing/mask/cigarette/dromedary
	desc = "A DromedaryCo brand cigarette. Contrary to popular belief, does not contain Calomel, but is reported to have a watery taste."
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/water = 5) //camel has water

/obj/item/clothing/mask/cigarette/uplift
	desc = "An Uplift Smooth brand cigarette. Smells refreshing."
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/consumable/menthol = 5)

/obj/item/clothing/mask/cigarette/robust
	desc = "A Robust brand cigarette."

/obj/item/clothing/mask/cigarette/robustgold
	desc = "A Robust Gold brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/gold = 3) // Just enough to taste a hint of expensive metal.

/obj/item/clothing/mask/cigarette/carp
	desc = "A Carp Classic brand cigarette. A small label on its side indicates that it does NOT contain carpotoxin."

/obj/item/clothing/mask/cigarette/carp/Initialize(mapload)
	. = ..()
	if(!prob(5))
		return
	reagents?.add_reagent(/datum/reagent/toxin/carpotoxin , 3) // They lied

/obj/item/clothing/mask/cigarette/syndicate
	desc = "An unknown brand cigarette."
	chem_volume = 60
	smoketime = 2 MINUTES
	smoke_all = TRUE
	lung_harm = 1.5
	list_reagents = list(/datum/reagent/drug/nicotine = 10, /datum/reagent/medicine/tricordrazine = 15)

/obj/item/clothing/mask/cigarette/shadyjims
	desc = "A Shady Jim's Super Slims cigarette."
	lung_harm = 1.5
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/toxin/lipolicide = 4, /datum/reagent/ammonia = 2, /datum/reagent/toxin/plantbgone = 1, /datum/reagent/toxin = 1.5)

/obj/item/clothing/mask/cigarette/xeno
	desc = "A Xeno Filtered brand cigarette."
	lung_harm = 2
	list_reagents = list (/datum/reagent/drug/nicotine = 20, /datum/reagent/medicine/regen_jelly = 15, /datum/reagent/drug/krokodil = 4)

// Rollies.

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	smoketime = 4 MINUTES
	chem_volume = 50
	list_reagents = null
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	name = pick(list(
		"bifta",
		"bifter",
		"bird",
		"blunt",
		"bloint",
		"boof",
		"boofer",
		"bomber",
		"bone",
		"bun",
		"doink",
		"doob",
		"doober",
		"doobie",
		"dutch",
		"fatty",
		"hogger",
		"hooter",
		"hootie",
		"\improper J",
		"jay",
		"jimmy",
		"joint",
		"juju",
		"jeebie weebie",
		"number",
		"owl",
		"phattie",
		"puffer",
		"reef",
		"reefer",
		"rollie",
		"scoobie",
		"shorty",
		"spiff",
		"spliff",
		"toke",
		"torpedo",
		"zoot",
		"zooter"))
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/nicotine
	list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/rollie/trippy
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/drug/mushroomhallucinogen = 35)
	starts_lit = TRUE

/obj/item/clothing/mask/cigarette/rollie/cannabis
	list_reagents = list(/datum/reagent/drug/cannabis = 15)

/obj/item/clothing/mask/cigarette/candy
	name = "\improper Little Timmy's candy cigarette"
	desc = "For all ages*! Doesn't contain any amount of nicotine. Health and safety risks can be read on the tip of the cigarette."
	smoketime = 2 MINUTES
	icon_state = "candyoff"
	icon_on = "candyon"
	icon_off = "candyoff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	inhand_icon_off = "candyoff"
	type_butt = /obj/item/food/candy_trash
	heat = 473.15 // Lowered so that the sugar can be carmalized, but not burnt.
	lung_harm = 0.5
	list_reagents = list(/datum/reagent/consumable/sugar = 20)
	supports_variations_flags = NONE

/obj/item/clothing/mask/cigarette/candy/nicotine
	desc = "For all ages*! Doesn't contain any* amount of nicotine. Health and safety risks can be read on the tip of the cigarette."
	type_butt = /obj/item/food/candy_trash/nicotine
	list_reagents = list(/datum/reagent/consumable/sugar = 20, /datum/reagent/drug/nicotine = 20) //oh no!
	smoke_all = TRUE //timmy's not getting out of this one

/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	inhand_icon_on = "cigaron"
	inhand_icon_off = "cigaroff"
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	smoketime = 11 MINUTES
	chem_volume = 40
	list_reagents = list(/datum/reagent/drug/nicotine = 25)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 20 MINUTES
	chem_volume = 80
	list_reagents = list(/datum/reagent/drug/nicotine = 40)
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 30 MINUTES
	chem_volume = 60
	list_reagents = list(/datum/reagent/drug/nicotine = 45)
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meerschaum or something."
	icon_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	inhand_icon_on = null
	inhand_icon_off = null
	smoketime = 0
	chem_volume = 200 // So we can fit densified chemicals plants
	list_reagents = null
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	///name of the stuff packed inside this pipe
	var/packeditem

/obj/item/clothing/mask/cigarette/pipe/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_NAME)

/obj/item/clothing/mask/cigarette/pipe/update_name()
	name = packeditem ? "[packeditem]-packed [initial(name)]" : "empty [initial(name)]"
	return ..()

/obj/item/clothing/mask/cigarette/pipe/put_out(mob/user, done_early = FALSE)
	lit = FALSE
	if(done_early)
		user.visible_message(span_notice("[user] puts out [src]."), span_notice("You put out [src]."))

	else
		if(user)
			to_chat(user, span_notice("Your [name] goes out."))
		packeditem = null
	update_icon()

	inhand_icon_state = icon_off
	user?.update_worn_mask()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/cigarette/pipe/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. == ITEM_INTERACT_ANY_BLOCKER)
		return

	if(!istype(tool, /obj/item/food/grown))
		return NONE

	var/obj/item/food/grown/to_smoke = tool
	if(packeditem)
		to_chat(user, span_warning("It is already packed."))
		return ITEM_INTERACT_BLOCKING

	if(!HAS_TRAIT(to_smoke, TRAIT_DRIED))
		to_chat(user, span_warning("It has to be dried first."))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You stuff [to_smoke] into [src]."))
	smoketime = 13 MINUTES
	packeditem = to_smoke.name
	update_appearance(UPDATE_NAME)
	if(to_smoke.reagents)
		to_smoke.reagents.trans_to(src, to_smoke.reagents.total_volume, transfered_by = user)
	qdel(to_smoke)
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user)
	var/atom/location = drop_location()
	if(packeditem && !lit)
		to_chat(user, span_notice("You empty [src] onto [location]."))
		new /obj/effect/decal/cleanable/ash(location)
		packeditem = null
		smoketime = 0
		reagents.clear_reagents()
		update_appearance(UPDATE_NAME)
		return
	return ..()

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters. Can be loaded with objects."
	icon_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	inhand_icon_on = null
	inhand_icon_off = null

/////////
//ZIPPO//
/////////
/obj/item/lighter
	name = "\improper Zippo lighter"
	desc = "The zippo."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "zippo"
	inhand_icon_state = "zippo"
	worn_icon_state = "lighter"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	heat = 1500
	resistance_flags = FIRE_PROOF
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/fuel/oil = 5)
	custom_price = PAYCHECK_ASSISTANT * 1.1
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 0.6
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	/// Whether the lighter is lit.
	var/lit = FALSE
	/// Whether the lighter is fancy. Fancy lighters have fancier flavortext and won't burn thumbs.
	var/fancy = TRUE
	/// The engraving overlay used by this lighter.
	var/overlay_state
	/// A list of possible engraving overlays.
	var/overlay_list = list(
		"plain",
		"dame",
		"thirteen",
		"snake"
		)

/obj/item/lighter/Initialize(mapload)
	. = ..()
	if(!overlay_state)
		overlay_state = pick(overlay_list)
	update_appearance()

/obj/item/lighter/cyborg_unequip(mob/user)
	if(!lit)
		return
	set_lit(FALSE)

/obj/item/lighter/suicide_act(mob/living/carbon/user)
	if (lit)
		user.visible_message(span_suicide("[user] begins holding \the [src]'s flame up to [user.p_their()] face! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		return FIRELOSS
	else
		user.visible_message(span_suicide("[user] begins whacking [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

/obj/item/lighter/update_icon_state()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	return ..()

/obj/item/lighter/update_overlays()
	. = ..()
	. += create_lighter_overlay()

/// Generates an overlay used by this lighter.
/obj/item/lighter/proc/create_lighter_overlay()
	return mutable_appearance(icon, "lighter_overlay_[overlay_state][lit ? "-on" : ""]")

/obj/item/lighter/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = span_infoplain(span_rose("With a single flick of [user.p_their()] wrist, [user] smoothly lights [A] with [src]. Damn [user.p_theyre()] cool."))

/obj/item/lighter/proc/set_lit(new_lit)
	if(lit == new_lit)
		return

	lit = new_lit
	if(lit)
		force = 5
		damtype = BURN
		hitsound = 'sound/items/welder.ogg'
		attack_verb_continuous = string_list(list("burns", "singes"))
		attack_verb_simple = string_list(list("burn", "singe"))
		START_PROCESSING(SSobj, src)
		playsound(loc, 'sound/items/lighter1.ogg', 100)
	else
		hitsound = SFX_SWING_HIT
		force = 0
		attack_verb_continuous = null //human_defense.dm takes care of it
		attack_verb_simple = null
		STOP_PROCESSING(SSobj, src)
		playsound(loc, 'sound/items/lighter2.ogg', 100)

	set_light_on(lit)
	update_appearance()

/obj/item/lighter/extinguish()
	set_lit(FALSE)

/obj/item/lighter/attack_self(mob/living/user)
	if(!user.is_holding(src))
		return ..()

	user.changeNext_move(CLICK_CD_RAPID)

	if(lit)
		set_lit(FALSE)
		if(fancy)
			user.visible_message(
				span_notice("You hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow."),
				span_notice("You quietly shut off [src] without even looking at what you're doing. Wow.")
			)
		else
			user.visible_message(
				span_notice("[user] quietly shuts off [src]."),
				span_notice("You quietly shut off [src].")
			)
		return

	set_lit(TRUE)

	if(fancy)
		user.visible_message(
			span_notice("Without even breaking stride, [user] flips open and lights [src] in one smooth movement."),
			span_notice("Without even breaking stride, you flip open and light [src] in one smooth movement.")
		)
		return

	var/hand_protected = FALSE
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user) || HAS_TRAIT(human_user, TRAIT_RESISTHEAT) || HAS_TRAIT(human_user, TRAIT_RESISTHEATHANDS))
		hand_protected = TRUE
	else if(!istype(human_user.gloves, /obj/item/clothing/gloves))
		hand_protected = FALSE
	else
		var/obj/item/clothing/gloves/gloves = human_user.gloves
		if(gloves.max_heat_protection_temperature)
			hand_protected = (gloves.max_heat_protection_temperature > 360)

	if(hand_protected)
		user.visible_message(
			span_notice("After a few attempts, [user] manages to light [src]."),
			span_notice("After a few attempts, you manage to light [src].")
		)
		return

	var/datum/roll_result/result = user.stat_roll(9, /datum/rpg_skill/handicraft)
	switch(result.outcome)
		if(FAILURE, CRIT_FAILURE)
			user.apply_damage(5, BURN, user.get_active_hand())
			to_chat(user, result.create_tooltip("Your eagerness to ignite [src] in a stylish fashion has shrouded your care. Your finger is bathed in the flame for a brief moment."))
		if(SUCCESS, CRIT_SUCCESS)
			to_chat(user, result.create_tooltip("After a few attempts, you manage to light [src]."))
	user.visible_message(span_notice("After a few attempts, [user] manages to light [src]."))

/obj/item/lighter/attack(mob/living/carbon/M, mob/living/carbon/user)
	. = ..()
	if(.)
		return

	if(lit && M.ignite_mob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")

/obj/item/lighter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!lit)
		return NONE

	if(!isliving(interacting_with))
		return NONE

	var/obj/item/clothing/mask/cigarette/to_light = help_light_cig(interacting_with)
	if(!to_light)
		return NONE

	if(to_light.lit)
		to_chat(user, span_warning("The [to_light.name] is already lit!"))
		return ITEM_INTERACT_BLOCKING

	if(interacting_with == user)
		to_light.item_interaction(src, user)
		return ITEM_INTERACT_SUCCESS

	if(fancy)
		to_light.light(span_rose("[user] whips the [name] out and holds it for [interacting_with]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] \the [to_light] with."))
	else
		to_light.light(span_notice("[user] holds the [name] out for [interacting_with], and lights [interacting_with.p_their()] [to_light.name]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/lighter/process()
	open_flame(heat)

/obj/item/lighter/get_temperature()
	return lit * heat


/obj/item/lighter/greyscale
	name = "cheap lighter"
	desc = "A cheap lighter."
	icon_state = "lighter"
	fancy = FALSE
	overlay_list = list(
		"transp",
		"tall",
		"matte",
		"zoppo" //u cant stoppo th zoppo
		)

	/// The color of the lighter.
	var/lighter_color
	/// The set of colors this lighter can be autoset as on init.
	var/list/color_list = list( //Same 16 color selection as electronic assemblies
		COLOR_ASSEMBLY_BLACK,
		COLOR_FLOORTILE_GRAY,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/lighter/greyscale/Initialize(mapload)
	. = ..()
	if(!lighter_color)
		lighter_color = pick(color_list)
	update_appearance()

/obj/item/lighter/greyscale/create_lighter_overlay()
	var/mutable_appearance/lighter_overlay = ..()
	lighter_overlay.color = lighter_color
	return lighter_overlay

/obj/item/lighter/greyscale/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = span_notice("After some fiddling, [user] manages to light [A] with [src].")


/obj/item/lighter/slime
	name = "slime zippo"
	desc = "A specialty zippo made from slimes and industry. Has a much hotter flame than normal."
	icon_state = "slighter"
	heat = 3000 //Blue flame!
	light_color = LIGHT_COLOR_CYAN
	overlay_state = "slime"
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5)


///////////
//ROLLING//
///////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/clothing/mask/cigarette/rollie, CUSTOM_INGREDIENT_ICON_NOCHANGE, ingredient_type=CUSTOM_INGREDIENT_TYPE_DRYABLE, max_ingredients=2)


///////////////
//VAPE NATION//
///////////////
/obj/item/clothing/mask/vape
	name = "\improper E-Cigarette"
	desc = "A classy and highly sophisticated electronic cigarette, for classy and dignified gentlemen. A warning label reads \"Warning: Do not fill with flammable materials.\""//<<< i'd vape to that.
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "red_vape"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_TINY

	/// The capacity of the vape.
	var/chem_volume = 100
	/// The amount of time between drags.
	var/dragtime = 8 SECONDS
	/// A cooldown to prevent huffing the vape all at once.
	COOLDOWN_DECLARE(drag_cooldown)
	/// Whether the resevoir is open and we can add reagents.
	var/screw = FALSE
	/// Whether the vape has been overloaded to spread smoke.
	var/super = FALSE
	/// Used to decide what overlay sprites to use.
	var/overlayname = "vape"

/obj/item/clothing/mask/vape/Initialize(mapload, param_color)
	. = ..()
	create_reagents(chem_volume, NO_REACT)
	reagents.add_reagent(/datum/reagent/drug/nicotine, 50)
	set_vape_color(param_color)

/obj/item/clothing/mask/vape/proc/set_vape_color(param_color)
	param_color ||= pick("red","blue","black","white","green","purple","yellow","orange")
	icon_state = "[param_color]_vape"
	inhand_icon_state = "[param_color]_vape"

/obj/item/clothing/mask/vape/cigar/set_vape_color()
	return

/obj/item/clothing/mask/vape/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is puffin hard on dat vape, [user.p_they()] trying to join the vape life on a whole notha plane!"))//it doesn't give you cancer, it is cancer
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/vape/screwdriver_act(mob/living/user, obj/item/tool)
	if(!screw)
		screw = TRUE
		to_chat(user, span_notice("You open the cap on [src]."))
		reagents.flags |= OPENCONTAINER
		if(obj_flags & EMAGGED)
			add_overlay("[overlayname]open_high")
		else if(super)
			add_overlay("[overlayname]open_med")
		else
			add_overlay("[overlayname]open_low")
	else
		screw = FALSE
		to_chat(user, span_notice("You close the cap on [src]."))
		reagents.flags &= ~(OPENCONTAINER)
		cut_overlays()

/obj/item/clothing/mask/vape/multitool_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(screw && !(obj_flags & EMAGGED))//also kinky
		if(!super)
			cut_overlays()
			super = TRUE
			to_chat(user, span_notice("You increase the voltage of [src]."))
			add_overlay("[overlayname]open_med")
		else
			cut_overlays()
			super = FALSE
			to_chat(user, span_notice("You decrease the voltage of [src]."))
			add_overlay("[overlayname]open_low")

	if(screw && (obj_flags & EMAGGED))
		to_chat(user, span_warning("[src] can't be modified!"))

/obj/item/clothing/mask/vape/emag_act(mob/user)// I WON'T REGRET WRITTING THIS, SURLY.
	if(screw)
		if(!(obj_flags & EMAGGED))
			cut_overlays()
			obj_flags |= EMAGGED
			super = FALSE
			to_chat(user, span_warning("You maximize the voltage of [src]."))
			add_overlay("[overlayname]open_high")
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread //for effect
			sp.set_up(5, 1, src)
			sp.start()
		else
			to_chat(user, span_warning("[src] is already emagged!"))
	else
		to_chat(user, span_warning("You need to open the cap to do that!"))

/obj/item/clothing/mask/vape/attack_self(mob/user)
	if(reagents.total_volume > 0)
		to_chat(user, span_notice("You empty [src] of all reagents."))
		reagents.clear_reagents()

/obj/item/clothing/mask/vape/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_MASK)
		return

	if(screw)
		to_chat(user, span_warning("You need to close the cap first!"))
		return

	add_trace_DNA(user.get_trace_dna())

	to_chat(user, span_notice("You start puffing on the vape."))
	reagents.flags &= ~(NO_REACT)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/vape/unequipped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_MASK) == src)
		reagents.flags |= NO_REACT
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/vape/proc/handle_reagents()
	if(!reagents.total_volume)
		return

	var/mob/living/carbon/vaper = loc
	if(!iscarbon(vaper) || src != vaper.wear_mask)
		reagents.remove_all(REAGENTS_METABOLISM)
		return

	if(reagents.get_reagent_amount(/datum/reagent/fuel))
		//HOT STUFF
		vaper.adjust_fire_stacks(2)
		vaper.ignite_mob()

	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start(src)
		qdel(src)

	if(!reagents.trans_to(vaper, REAGENTS_METABOLISM, methods = INJECT)) //Going right into the bloodstream
		reagents.remove_all(REAGENTS_METABOLISM)

/obj/item/clothing/mask/vape/process(delta_time)
	var/mob/living/M = loc

	if(isliving(loc))
		M.ignite_mob()

	if(!reagents.total_volume)
		if(equipped_to)
			to_chat(equipped_to, span_warning("[src] is empty!"))
			. = PROCESS_KILL
			//it's reusable so it won't unequip when empty
		return

	if(!COOLDOWN_FINISHED(src, drag_cooldown))
		return

	//Time to start puffing those fat vapes, yo.
	COOLDOWN_START(src, drag_cooldown, dragtime)
	if(obj_flags & EMAGGED)
		var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/s = new
		s.set_up(4, location = loc, carry = reagents, efficiency = 24)
		s.start()
		if(prob(5)) //small chance for the vape to break and deal damage if it's emagged
			playsound(get_turf(src), 'sound/effects/pop_expl.ogg', 50, FALSE)
			M.apply_damage(20, BURN, BODY_ZONE_HEAD)
			M.Paralyze(300)
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
			sp.set_up(5, 1, src)
			sp.start()
			to_chat(M, span_userdanger("[src] suddenly explodes in your mouth!"))
			qdel(src)
			return
	else if(super)
		var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/s = new
		s.set_up(1, location = loc, carry = reagents, efficiency = 24)
		s.start()

	handle_reagents()

/obj/item/clothing/mask/vape/cigar
	name = "\improper E-Cigar"
	desc = "The latest recreational device developed by a small tech startup, Shadow Tech, the E-Cigar has all the uses of a normal E-Cigarette, with the classiness of short fat cigar."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "ecigar_vape"
	overlayname = "ecigar"
	chem_volume = 150
	custom_premium_price = 300
