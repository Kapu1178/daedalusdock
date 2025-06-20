TYPEINFO_DEF(/obj/vehicle/ridden/wheelchair)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 20, ACID = 30)

/obj/vehicle/ridden/wheelchair //ported from Hippiestation (by Jujumatic)
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	density = FALSE //Thought I couldn't fix this one easily, phew
	/// Run speed delay is multiplied with this for vehicle move delay.
	var/delay_multiplier = 6.7
	/// This variable is used to specify which overlay icon is used for the wheelchair, ensures wheelchair can cover your legs
	var/overlay_icon = "wheelchair_overlay"
	var/image/wheels_overlay
	///Determines the typepath of what the object folds into
	var/foldabletype = /obj/item/wheelchair

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	make_ridable()
	wheels_overlay = image(icon, overlay_icon, ABOVE_MOB_LAYER)
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT)
	AddComponent(/datum/component/simple_rotation) //Since it's technically a chair I want it to have chair properties

/obj/vehicle/ridden/wheelchair/atom_destruction(damage_flag)
	new /obj/item/stack/rods(drop_location(), 1)
	new /obj/item/stack/sheet/iron(drop_location(), 1)
	return ..()

/obj/vehicle/ridden/wheelchair/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!forced && !CHECK_MOVE_LOOP_FLAGS(src, MOVEMENT_LOOP_OUTSIDE_CONTROL) && has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 75, TRUE)

/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	update_appearance()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob()
	. = ..()
	update_appearance()

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/I) //Attackby should stop it attacking the wheelchair after moving away during decon
	..()
	to_chat(user, span_notice("You begin to detach the wheels..."))
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You detach the wheels and deconstruct the chair."))
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/iron(drop_location(), 4)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/wheelchair/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/vehicle/ridden/wheelchair/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		. += wheels_overlay

/// I assign the ridable element in this so i don't have to fuss with hand wheelchairs and motor wheelchairs having different subtypes
/obj/vehicle/ridden/wheelchair/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair/hand)

TYPEINFO_DEF(/obj/vehicle/ridden/wheelchair/gold)
	default_armor = list(BLUNT = 20, PUNCTURE = 20, SLASH = 0, LASER = 20, ENERGY = 0, BOMB = 20, BIO = 0, FIRE = 30, ACID = 40)
	default_materials = list(/datum/material/gold = 10000)

/obj/vehicle/ridden/wheelchair/gold
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS
	desc = "Damn, he's been through a lot."
	icon_state = "gold_wheelchair"
	overlay_icon = "gold_wheelchair_overlay"
	max_integrity = 200
	foldabletype = /obj/item/wheelchair/gold

TYPEINFO_DEF(/obj/item/wheelchair)
	default_materials = list(/datum/material/iron = 10000)

/obj/item/wheelchair
	name = "wheelchair"
	desc = "A collapsed wheelchair that can be carried around."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair_folded"
	inhand_icon_state = "wheelchair_folded"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 8 //Force is same as a chair
	///The wheelchair vehicle type we create when we unfold this chair
	var/unfolded_type = /obj/vehicle/ridden/wheelchair

TYPEINFO_DEF(/obj/item/wheelchair/gold)
	default_materials = list(/datum/material/gold = 10000)

/obj/item/wheelchair/gold
	name = "gold wheelchair"
	desc = "A collapsed, shiny wheelchair that can be carried around."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair_folded_gold"
	inhand_icon_state = "wheelchair_folded_gold"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	unfolded_type = /obj/vehicle/ridden/wheelchair/gold

/obj/vehicle/ridden/wheelchair/MouseDrop(over_object, src_location, over_location)  //Lets you collapse wheelchair
	. = ..()
	if(over_object != usr || !Adjacent(usr) || !foldabletype)
		return FALSE
	if(!ishuman(usr) || !usr.canUseTopic(src, USE_CLOSE))
		return FALSE
	if(has_buckled_mobs())
		return FALSE
	usr.visible_message(span_notice("[usr] collapses [src]."), span_notice("You collapse [src]."))
	var/obj/vehicle/ridden/wheelchair/wheelchair_folded = new foldabletype(get_turf(src))
	usr.put_in_hands(wheelchair_folded)
	qdel(src)

/obj/item/wheelchair/attack_self(mob/user)  //Deploys wheelchair on in-hand use
	deploy_wheelchair(user, user.loc)

/obj/item/wheelchair/proc/deploy_wheelchair(mob/user, atom/location)
	var/obj/vehicle/ridden/wheelchair/wheelchair_unfolded = new unfolded_type(location)
	wheelchair_unfolded.add_fingerprint(user)
	qdel(src)
