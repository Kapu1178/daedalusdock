#define INFINITE -1

/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant, skillchip or organ into the user without the hassle of extensive surgery. \
		It has a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	inhand_icon_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL

	var/uses = INFINITE

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/organ
	name = "implant autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. \
		It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."

	var/organ_type = /obj/item/organ
	var/starting_organ
	var/obj/item/organ/storedorgan
	var/surgery_speed = 1

/obj/item/autosurgeon/organ/syndicate
	name = "suspicious implant autosurgeon"
	icon_state = "syndicate_autoimplanter"
	surgery_speed = 0.75

/obj/item/autosurgeon/organ/Initialize(mapload)
	. = ..()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/autosurgeon/organ/proc/insert_organ(obj/item/item)
	storedorgan = item
	item.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/autosurgeon/organ/proc/use_autosurgeon()
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/organ/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, span_alert("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_alert("[src] currently has no implant stored."))
		return
	storedorgan.Insert(user)//insert stored organ into the user
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You feel a sharp sting as [src] plunges into your body."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)
	use_autosurgeon()

/obj/item/autosurgeon/organ/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, organ_type))
		if(storedorgan)
			to_chat(user, span_alert("[src] already has an implant stored."))
			return
		else if(!uses)
			to_chat(user, span_alert("[src] has already been used up."))
			return
		if(!user.transferItemToLoc(weapon, src))
			return
		storedorgan = weapon
		to_chat(user, span_notice("You insert the [weapon] into [src]."))
	else
		return ..()

/obj/item/autosurgeon/organ/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE


	user.visible_message(
		"[user] prepares to use [src] on [interacting_with].",
		"You begin to prepare to use [src] on [interacting_with]."
	)

	if(!do_after(user, interacting_with, (8 SECONDS * surgery_speed)))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You press a button on [src] as it plunges into [interacting_with]'s body."))
	to_chat(interacting_with, span_notice("You feel a sharp sting as something plunges into your body!"))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, vary = TRUE)
	storedorgan.Insert(interacting_with) //let's actually get the organ into the target, yeah?
	use_autosurgeon()
	return ITEM_INTERACT_SUCCESS

/obj/item/autosurgeon/organ/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, span_warning("There's no implant in [src] for you to remove!"))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/atom/movable/stored_implant as anything in src)
			stored_implant.forceMove(drop_loc)

		to_chat(user, span_notice("You remove the [storedorgan] from [src]."))
		screwtool.play_tool_sound(src)
		use_autosurgeon()
	return TRUE

/obj/item/autosurgeon/organ/cmo
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/medical

/obj/item/autosurgeon/organ/syndicate/laser_arm
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/gun/laser

/obj/item/autosurgeon/organ/syndicate/thermal_eyes
	starting_organ = /obj/item/organ/eyes/robotic/thermals

/obj/item/autosurgeon/organ/syndicate/xray_eyes
	starting_organ = /obj/item/organ/eyes/robotic/xray

/obj/item/autosurgeon/organ/syndicate/anti_stun
	starting_organ = /obj/item/organ/cyberimp/brain/anti_stun

/obj/item/autosurgeon/organ/syndicate/reviver
	starting_organ = /obj/item/organ/cyberimp/chest/reviver
