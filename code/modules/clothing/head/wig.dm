/obj/item/clothing/head/wig
	name = "wig"
	desc = "A bunch of hair without a head attached."
	icon = 'icons/mob/hair.dmi'   // default icon for all hairs
	icon_state = "hair_vlong"
	inhand_icon_state = "pwig"
	worn_icon_state = "wig"
	flags_inv = HIDEHAIR
	color = "#000000"
	var/hairstyle = "Very Long Hair"
	var/adjustablecolor = TRUE //can color be changed manually?

/obj/item/clothing/head/wig/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/clothing/head/wig/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && slot == ITEM_SLOT_HEAD)
		item_flags |= EXAMINE_SKIP

/obj/item/clothing/head/wig/unequipped(mob/user)
	. = ..()
	item_flags &= ~EXAMINE_SKIP

/obj/item/clothing/head/wig/update_icon_state()
	var/datum/sprite_accessory/hair_style = GLOB.hairstyles_list[hairstyle]
	if(hair_style)
		icon_state = hair_style.icon_state
	return ..()


/obj/item/clothing/head/wig/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands = FALSE, file2use)
	. = ..()
	if(isinhands)
		return

	var/datum/sprite_accessory/hair = GLOB.hairstyles_list[hairstyle]
	if(!hair)
		return

	var/mutable_appearance/hair_overlay = mutable_appearance(hair.icon, hair.icon_state, layer = -HAIR_LAYER, appearance_flags = RESET_COLOR)
	hair_overlay.color = color
	. += hair_overlay

	// So that the wig actually blocks emissives.
	hair_overlay.overlays += emissive_blocker(hair_overlay.icon, hair_overlay.icon_state, alpha = hair_overlay.alpha)

/obj/item/clothing/head/wig/attack_self(mob/user)
	var/new_style = tgui_input_list(user, "Select a hairstyle", "Wig Styling", GLOB.hairstyles_list - "Bald")
	var/newcolor = adjustablecolor ? input(usr,"","Choose Color",color) as color|null : null
	if(!user.canUseTopic(src, USE_CLOSE))
		return
	if(new_style && new_style != hairstyle)
		hairstyle = new_style
		user.visible_message(span_notice("[user] changes \the [src]'s hairstyle to [new_style]."), span_notice("You change \the [src]'s hairstyle to [new_style]."))
	if(newcolor && newcolor != color) // only update if necessary
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
	update_appearance()

/obj/item/clothing/head/wig/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return

	var/mob/living/carbon/human/target = interacting_with
	if(!istype(target))
		return NONE

	if(target.head)
		var/obj/item/clothing/head = target.head
		if((head.flags_inv & HIDEHAIR) && !istype(head, /obj/item/clothing/head/wig))
			to_chat(user, span_warning("You can't get a good look at [target.p_their()] hair."))
			return ITEM_INTERACT_BLOCKING

	var/selected_hairstyle = null
	var/selected_hairstyle_color = null
	if(istype(target.head, /obj/item/clothing/head/wig))
		var/obj/item/clothing/head/wig/wig = target.head
		selected_hairstyle = wig.hairstyle
		selected_hairstyle_color = wig.color
	else if(target.has_hair(TRUE))
		selected_hairstyle = target.hairstyle
		selected_hairstyle_color = "[target.hair_color]"

	if(selected_hairstyle)
		to_chat(user, span_notice("You adjust the [src] to look just like [target.name]'s [selected_hairstyle]."))
		add_atom_colour(selected_hairstyle_color, FIXED_COLOUR_PRIORITY)
		hairstyle = selected_hairstyle
		update_appearance()

	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/head/wig/random/Initialize(mapload)
	hairstyle = pick(GLOB.hairstyles_list - "Bald") //Don't want invisible wig
	add_atom_colour("#[random_short_color()]", FIXED_COLOUR_PRIORITY)
	. = ..()

/obj/item/clothing/head/wig/natural
	name = "natural wig"
	desc = "A bunch of hair without a head attached. This one changes color to match the hair of the wearer. Nothing natural about that."
	color = "#FFFFFF"
	adjustablecolor = FALSE
	custom_price = PAYCHECK_ASSISTANT * 2.25

/obj/item/clothing/head/wig/natural/Initialize(mapload)
	hairstyle = pick(GLOB.hairstyles_list - "Bald")
	. = ..()

/obj/item/clothing/head/wig/natural/visual_equipped(mob/living/carbon/human/user, slot)
	if(ishuman(user) && slot == ITEM_SLOT_HEAD)
		if (color != user.hair_color) // only update if necessary
			add_atom_colour(user.hair_color, FIXED_COLOUR_PRIORITY)
			update_appearance()
	return ..()
