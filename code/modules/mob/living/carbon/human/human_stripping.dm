#define INTERNALS_TOGGLE_DELAY (4 SECONDS)
#define POCKET_EQUIP_DELAY (1 SECONDS)

GLOBAL_LIST_INIT(strippable_human_items, create_strippable_list(list(
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/neck,
	/datum/strippable_item/mob_item_slot/eyes,
	/datum/strippable_item/mob_item_slot/ears,
	/datum/strippable_item/mob_item_slot/jumpsuit,
	/datum/strippable_item/mob_item_slot/suit,
	/datum/strippable_item/mob_item_slot/gloves,
	/datum/strippable_item/mob_item_slot/feet,
	/datum/strippable_item/mob_item_slot/suit_storage,
	/datum/strippable_item/mob_item_slot/id,
	/datum/strippable_item/mob_item_slot/belt,
	/datum/strippable_item/mob_item_slot/pocket/left,
	/datum/strippable_item/mob_item_slot/pocket/right,
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

/mob/living/carbon/human/should_strip(mob/living/user)
	. = ..()
	if (!.)
		return FALSE

	var/obj/item/hand_item/grab/G = user.is_grabbing(src)
	if(!G)
		return TRUE

	if ((G.current_grab.damage_stage == GRAB_AGGRESSIVE) && !combat_mode) // Do not conflict with fireman carrying
		return FALSE

/datum/strippable_item/mob_item_slot/eyes
	key = STRIPPABLE_ITEM_EYES
	item_slot = ITEM_SLOT_EYES

/datum/strippable_item/mob_item_slot/ears
	key = STRIPPABLE_ITEM_EARS
	item_slot = ITEM_SLOT_EARS

/datum/strippable_item/mob_item_slot/jumpsuit
	key = STRIPPABLE_ITEM_JUMPSUIT
	item_slot = ITEM_SLOT_ICLOTHING

/datum/strippable_item/mob_item_slot/jumpsuit/get_alternate_action(atom/source, mob/user, action)
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if (!istype(jumpsuit))
		return null
	return jumpsuit?.can_adjust ? "adjust_jumpsuit" : null

/datum/strippable_item/mob_item_slot/jumpsuit/alternate_action(atom/source, mob/user, action)
	if (!..())
		return
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if (!istype(jumpsuit))
		return null
	to_chat(source, "<span class='notice'>[user] is trying to adjust your [jumpsuit.name].")
	if (!do_after(user, source, jumpsuit.strip_delay * 0.5))
		return
	to_chat(source, "<span class='notice'>[user] successfully adjusted your [jumpsuit.name].")
	jumpsuit.toggle_jumpsuit_adjust()

	if (!ismob(source))
		return

	if(iscarbon(source))
		var/mob/living/carbon/carbon_source = source
		carbon_source.update_slots_for_item(source)

/datum/strippable_item/mob_item_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_OCLOTHING

/datum/strippable_item/mob_item_slot/gloves
	key = STRIPPABLE_ITEM_GLOVES
	item_slot = ITEM_SLOT_GLOVES

/datum/strippable_item/mob_item_slot/feet
	key = STRIPPABLE_ITEM_FEET
	item_slot = ITEM_SLOT_FEET

/datum/strippable_item/mob_item_slot/feet/start_unequip_mob(obj/item/item, mob/source, mob/user, strip_delay)
	if(ishuman(source))
		var/mob/living/carbon/human/victim = source
		if(victim.body_position == STANDING_UP)
			strip_delay += 3 SECONDS
	return ..()

/datum/strippable_item/mob_item_slot/feet/get_alternate_action(atom/source, mob/user, action)
	var/obj/item/clothing/shoes/shoes = get_item(source)
	if (!istype(shoes) || !shoes.can_be_tied)
		return null

	switch (shoes.tied)
		if (SHOES_UNTIED)
			return "knot"
		if (SHOES_TIED)
			return "untie"
		if (SHOES_KNOTTED)
			return "unknot"

/datum/strippable_item/mob_item_slot/feet/alternate_action(atom/source, mob/user, action)
	if(!..())
		return
	var/obj/item/clothing/shoes/shoes = get_item(source)
	if (!istype(shoes))
		return

	shoes.handle_tying(user)

/datum/strippable_item/mob_item_slot/suit_storage
	key = STRIPPABLE_ITEM_SUIT_STORAGE
	item_slot = ITEM_SLOT_SUITSTORE

/datum/strippable_item/mob_item_slot/suit_storage/get_alternate_action(atom/source, mob/user, action)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/suit_storage/alternate_action(atom/source, mob/user, action)
	if (!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/id
	key = STRIPPABLE_ITEM_ID
	item_slot = ITEM_SLOT_ID

/datum/strippable_item/mob_item_slot/belt
	key = STRIPPABLE_ITEM_BELT
	item_slot = ITEM_SLOT_BELT

/datum/strippable_item/mob_item_slot/belt/get_alternate_action(atom/source, mob/user, action)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/belt/alternate_action(atom/source, mob/user, action)
	if (!..())
		return
	strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/pocket
	/// Which pocket we're referencing. Used for visible text.
	var/pocket_side

/datum/strippable_item/mob_item_slot/pocket/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/pocket/get_equip_delay(obj/item/equipping)
	return POCKET_EQUIP_DELAY

/datum/strippable_item/mob_item_slot/pocket/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		warn_owner(source)

/datum/strippable_item/mob_item_slot/pocket/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	to_chat(user, span_notice("You try to empty [source]'s [pocket_side] pocket."))

	var/log_message = "[key_name(source)] is being pickpocketed of [item] by [key_name(user)] ([pocket_side])"
	user.log_message(log_message, LOG_ATTACK, color="red")
	source.log_message(log_message, LOG_VICTIM, color="red", log_globally=FALSE)
	item.add_fingerprint(src)

	var/result = start_unequip_mob(item, source, user, POCKET_STRIP_DELAY)

	if (!result)
		warn_owner(source)

	return result

/datum/strippable_item/mob_item_slot/pocket/proc/warn_owner(atom/owner)
	to_chat(owner, span_warning("You feel your [pocket_side] pocket being fumbled with!"))

/datum/strippable_item/mob_item_slot/pocket/left
	key = STRIPPABLE_ITEM_LPOCKET
	item_slot = ITEM_SLOT_LPOCKET
	pocket_side = "left"

/datum/strippable_item/mob_item_slot/pocket/right
	key = STRIPPABLE_ITEM_RPOCKET
	item_slot = ITEM_SLOT_RPOCKET
	pocket_side = "right"

/proc/get_strippable_alternate_action_internals(obj/item/item, atom/source)
	if (!iscarbon(source))
		return

	var/mob/living/carbon/carbon_source = source

	if (carbon_source.can_breathe_internals() && istype(item, /obj/item/tank))
		if(carbon_source.internal != item)
			return "enable_internals"
		else
			return "disable_internals"

/proc/strippable_alternate_action_internals(obj/item/item, atom/source, mob/user)
	var/obj/item/tank/tank = item
	if (!istype(tank))
		return

	var/mob/living/carbon/carbon_source = source
	if (!istype(carbon_source))
		return

	if (!carbon_source.can_breathe_internals())
		return

	carbon_source.visible_message(
		span_danger("[user] tries to [carbon_source.internal != item ? "open": "close"] the valve on [source]'s [item.name]."),
		span_userdanger("[user] tries to [carbon_source.internal != item ? "open": "close"] the valve on your [item.name]."),
		ignored_mobs = user,
	)

	to_chat(user, span_notice("You try to [carbon_source.internal != item  ? "open": "close"] the valve on [source]'s [item.name]..."))

	if(!do_after(user, carbon_source, INTERNALS_TOGGLE_DELAY))
		return

	if (carbon_source.internal == item)
		carbon_source.close_internals()

	else if (!QDELETED(item))
		if(!carbon_source.try_open_internals(item))
			return

	carbon_source.visible_message(
		span_danger("[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on [source]'s [item.name]."),
		span_userdanger("[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on your [item.name]."),
		ignored_mobs = user,
	)

	to_chat(user, span_notice("You [isnull(carbon_source.internal) ? "close" : "open"] the valve on [source]'s [item.name]."))

#undef INTERNALS_TOGGLE_DELAY
#undef POCKET_EQUIP_DELAY
