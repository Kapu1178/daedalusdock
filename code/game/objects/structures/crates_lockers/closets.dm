#define LOCKER_FULL -1

DEFINE_INTERACTABLE(/obj/structure/closet)
TYPEINFO_DEF(/obj/structure/closet)
	default_armor = list(BLUNT = 20, PUNCTURE = 10, SLASH = 70, LASER = 10, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 70, ACID = 60)

/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	drag_slowdown = 1.5 // Same as a prone mob
	max_integrity = 200
	integrity_failure = 0.25
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	pass_flags_self = PASSSTRUCTURE|LETPASSCLICKS
	zmm_flags = ZMM_MANGLE_PLANES

	/// The overlay for the closet's door
	var/obj/effect/overlay/closet_door/door_obj
	/// Whether or not this door is being animated
	var/is_animating_door = FALSE
	/// Vertical squish of the door
	var/door_anim_squish = 0.12
	/// The maximum angle the door will be drawn at
	var/door_anim_angle = 136
	/// X position of the closet door hinge
	var/door_hinge_x = -6.5
	/// Amount of time it takes for the door animation to play
	var/door_anim_time = 1.5 // set to 0 to make the door not animate at all

	/// Controls whether a door overlay should be applied using the icon_door value as the icon state
	var/enable_door_overlay = TRUE
	var/has_opened_overlay = TRUE
	var/has_closed_overlay = TRUE
	var/icon_door = null
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/breakout_time = 1200
	var/message_cooldown
	var/can_weld_shut = TRUE
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/cutting_tool = /obj/item/weldingtool
	var/open_sound = 'sound/structures/locker_open.ogg'
	var/close_sound = 'sound/structures/locker_close.ogg'
	var/open_sound_volume = 50
	var/close_sound_volume = 50
	var/material_drop = /obj/item/stack/sheet/iron
	var/material_drop_amount = 2
	var/delivery_icon = "deliverycloset" //which icon to use when packagewrapped. null to be unwrappable.
	var/anchorable = TRUE
	var/icon_welded = "welded"
	/// How close being inside of the thing provides complete pressure safety. Must be between 0 and 1!
	contents_pressure_protection = 0
	/// How insulated the thing is, for the purposes of calculating body temperature. Must be between 0 and 1!
	contents_thermal_insulation = 0
	/// Whether a skittish person can dive inside this closet. Disable if opening the closet causes "bad things" to happen or that it leads to a logical inconsistency.
	var/divable = TRUE
	/// true whenever someone with the strong pull component (or magnet modsuit module) is dragging this, preventing opening
	var/strong_grab = FALSE
	///electronics for access
	var/obj/item/electronics/airlock/electronics
	var/can_install_electronics = TRUE

/obj/structure/closet/Initialize(mapload)
	. = ..()
	update_appearance()
	PopulateContents()
	if(QDELETED(src)) //It turns out populate contents has a 1 in 100 chance of qdeling src on /obj/structure/closet/emcloset
		return //Why
	var/static/list/loc_connections = list(
		COMSIG_CARBON_DISARM_COLLIDE = PROC_REF(locker_carbon),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	register_context()
	if(mapload && !opened)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/closet/LateInitialize()
	. = ..()
	take_contents()

/obj/structure/closet/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!isliving(user) || astype(user, /mob/living).combat_mode || broken)
		return NONE

	if(held_item)
		if(opened)
			if(istype(held_item, cutting_tool))
				context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
				return CONTEXTUAL_SCREENTIP_SET

			context[SCREENTIP_CONTEXT_LMB] = "Insert object"
			return CONTEXTUAL_SCREENTIP_SET

		else
			if(secure && held_item.GetID())
				context[SCREENTIP_CONTEXT_LMB] = locked ? "Unlock" : "Lock"
				return CONTEXTUAL_SCREENTIP_SET

			else if(can_weld_shut && held_item.tool_behaviour == TOOL_WELDER)
				context[SCREENTIP_CONTEXT_LMB] = welded ? "Unweld" : "Weld"
				return CONTEXTUAL_SCREENTIP_SET

		return NONE

	if(welded || locked)
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = opened ? "Close" : "Open"
	if(secure)
		context[SCREENTIP_CONTEXT_RMB] = locked ? "Unlock" : "Lock"

	return CONTEXTUAL_SCREENTIP_SET

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	QDEL_NULL(door_obj)
	QDEL_NULL(electronics)
	return ..()

/obj/structure/closet/update_appearance(updates=ALL)
	. = ..()
	if(opened || broken || !secure)
		luminosity = 0
		return
	luminosity = 1

/obj/structure/closet/update_icon()
	. = ..()
	if(istype(src, /obj/structure/closet/supplypod))
		return

	layer = opened ? BELOW_OBJ_LAYER : OBJ_LAYER

/obj/structure/closet/update_overlays()
	. = ..()
	closet_update_overlays(.)

/obj/structure/closet/proc/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(enable_door_overlay && !is_animating_door)
		if(opened && has_opened_overlay)
			var/mutable_appearance/door_overlay = mutable_appearance(icon, "[icon_state]_open", alpha = src.alpha)
			. += door_overlay
			door_overlay.overlays += emissive_blocker(door_overlay.icon, door_overlay.icon_state, alpha = door_overlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.
		else if(has_closed_overlay)
			. += "[icon_door || icon_state]_door"

	if(opened)
		return

	if(welded)
		. += icon_welded

	if(broken || !secure)
		return
	//Overlay is similar enough for both that we can use the same mask for both
	. += emissive_appearance(icon, "locked", alpha = 90)
	. += locked ? "locked" : "unlocked"

/// Animates the closet door opening and closing
/obj/structure/closet/proc/animate_door(closing = FALSE)
	if(!door_anim_time)
		return
	if(!door_obj)
		door_obj = new
	var/default_door_icon = "[icon_door || icon_state]_door"
	add_viscontents(door_obj)
	door_obj.icon = icon
	door_obj.icon_state = default_door_icon
	is_animating_door = TRUE
	var/num_steps = door_anim_time / world.tick_lag

	for(var/step in 0 to num_steps)
		var/angle = door_anim_angle * (closing ? 1 - (step/num_steps) : (step/num_steps))
		var/matrix/door_transform = get_door_transform(angle)
		var/door_state
		var/door_layer

		if (angle >= 90)
			door_state = "[icon_state]_back"
			door_layer = FLOAT_LAYER
		else
			door_state = default_door_icon
			door_layer = ABOVE_MOB_LAYER

		if(step == 0)
			door_obj.transform = door_transform
			door_obj.icon_state = door_state
			door_obj.layer = door_layer
		else if(step == 1)
			animate(door_obj, transform = door_transform, icon_state = door_state, layer = door_layer, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = door_transform, icon_state = door_state, layer = door_layer, time = world.tick_lag)
	addtimer(CALLBACK(src, PROC_REF(end_door_animation)), door_anim_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_CLIENT_TIME)

/// Ends the door animation and removes the animated overlay
/obj/structure/closet/proc/end_door_animation()
	is_animating_door = FALSE
	remove_viscontents(door_obj)
	update_icon()

/// Calculates the matrix to be applied to the animated door overlay
/obj/structure/closet/proc/get_door_transform(angle)
	var/matrix/door_matrix = matrix()
	door_matrix.Translate(-door_hinge_x, 0)
	door_matrix.Multiply(matrix(cos(angle), 0, 0, -sin(angle) * door_anim_squish, 1, 0))
	door_matrix.Translate(door_hinge_x, 0)
	return door_matrix

/obj/structure/closet/examine(mob/user)
	. = ..()
	if(welded)
		. += span_notice("It is welded shut.")
	if(anchored)
		. += span_notice("It is <b>bolted</b> to the ground.")

	if(opened && ispath(cutting_tool, /obj/item/weldingtool))
		. += span_notice("The parts are <b>welded</b> together.")

/obj/structure/closet/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(wall_mounted)
		return TRUE

/obj/structure/closet/proc/can_open(mob/living/user, force = FALSE)
	if(force)
		return TRUE
	if(welded || locked)
		return FALSE
	if(strong_grab)
		var/obj/item/hand_item/grab/G = grabbed_by[1]
		to_chat(user, span_danger("[G.assailant] has an incredibly strong grip on [src], preventing it from opening."))
		return FALSE
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, span_danger("There's something large on top of [src], preventing it from opening."))
			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/closet in T)
		if(closet != src && !closet.wall_mounted)
			return FALSE
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, span_danger("There's something too large in [src], preventing it from closing."))
			return FALSE
	return TRUE

/obj/structure/closet/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents(mapload = FALSE)
	var/atom/location = drop_location()
	if(!location)
		return
	for(var/atom/movable/AM as anything in location)
		if(iseffect(AM))
			continue

		if(AM != src && insert(AM, mapload) == LOCKER_FULL) // limit reached
			if(mapload) // Yea, it's a mapping issue. Blame mappers.
				log_mapping("Closet storage capacity of [type] exceeded on mapload at [AREACOORD(src)]")
			break
	for(var/atom/movable/thing as anything in reverse_range(location.get_all_contents()))
		thing.atom_storage?.close_all()

/obj/structure/closet/proc/open(mob/living/user, force = FALSE)
	if(!can_open(user, force))
		return
	if(opened)
		return
	if(SEND_SIGNAL(src, COMSIG_CLOSET_PRE_OPEN, user, force) & BLOCK_OPEN)
		return
	welded = FALSE
	locked = FALSE
	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	opened = TRUE
	if(!dense_when_open)
		set_density(FALSE)
	dump_contents()
	animate_door(FALSE)
	update_appearance()

	after_open(user, force)
	SEND_SIGNAL(src, COMSIG_CLOSET_POST_OPEN, force)
	return TRUE

///Proc to override for effects after opening a door
/obj/structure/closet/proc/after_open(mob/living/user, force = FALSE)
	return

/obj/structure/closet/proc/insert(atom/movable/inserted, mapload = FALSE)
	if(length(contents) >= storage_capacity)
		if(!mapload)
			return LOCKER_FULL
		//For maploading, we only return LOCKER_FULL if the movable was otherwise insertable. This way we can avoid logging false flags.
		return insertion_allowed(inserted) ? LOCKER_FULL : FALSE
	if(!insertion_allowed(inserted))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_CLOSET_INSERT, inserted) & COMPONENT_CLOSET_INSERT_INTERRUPT)
		return TRUE
	inserted.forceMove(src)
	return TRUE

/obj/structure/closet/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
		L.release_all_grabs()

	else if(istype(AM, /obj/structure/closet))
		return FALSE
	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects && !istype(AM, /obj/effect/dummy/chameleon))
			return FALSE
		else if(HAS_TRAIT(AM, TRAIT_REJECT_INSERTION))
			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE
	take_contents()
	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	opened = FALSE
	set_density(TRUE)
	animate_door(TRUE)
	update_appearance()
	after_close(user)
	return TRUE

///Proc to override for effects after closing a door
/obj/structure/closet/proc/after_close(mob/living/user)
	return

/**
 * Toggles a closet open or closed, to the opposite state. Does not respect locked or welded states, however.
 */
/obj/structure/closet/proc/toggle(mob/living/user)
	if(user)
		user.animate_interact(src)

	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if (!(flags_1 & NODECONSTRUCT_1))
		if(ispath(material_drop) && material_drop_amount)
			new material_drop(loc, material_drop_amount)
		if (electronics)
			var/obj/item/electronics/airlock/electronics_ref = electronics
			electronics = null
			electronics_ref.forceMove(drop_location())
	dump_contents()
	qdel(src)

/obj/structure/closet/atom_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()

/obj/structure/closet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user in src)
		return ITEM_INTERACT_BLOCKING
	return tool_interact(tool, user)

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	return ..()

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/living/user)//returns TRUE if attackBy call shouldn't be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = ITEM_INTERACT_SUCCESS
	if(opened)
		if(istype(W, cutting_tool))
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return ITEM_INTERACT_BLOCKING

				to_chat(user, span_notice("You begin cutting \the [src] apart..."))
				if(W.use_tool(src, user, 40, volume=50))
					if(!opened)
						return ITEM_INTERACT_BLOCKING
					user.visible_message(span_notice("[user] slices apart \the [src]."),
									span_notice("You cut \the [src] apart with \the [W]."),
									span_hear("You hear welding."))
					deconstruct(TRUE)
				return ITEM_INTERACT_SUCCESS

			else // for example cardboard box is cut with wirecutters
				user.visible_message(span_notice("[user] cut apart \the [src]."), \
									span_notice("You cut \the [src] apart with \the [W]."))
				deconstruct(TRUE)
				return ITEM_INTERACT_SUCCESS

		if(user.transferItemToLoc(W, drop_location())) // so we put in unlit welder too
			return ITEM_INTERACT_SUCCESS

	else if(W.tool_behaviour == TOOL_WELDER && can_weld_shut)
		if(!W.tool_start_check(user, amount=0))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You begin [welded ? "unwelding":"welding"] \the [src]..."))
		if(W.use_tool(src, user, 40, volume=50))
			if(opened)
				return ITEM_INTERACT_BLOCKING

			welded = !welded
			after_weld(welded)
			user.visible_message(span_notice("[user] [welded ? "welds shut" : "unwelded"] \the [src]."),
							span_notice("You [welded ? "weld" : "unwelded"] \the [src] with \the [W]."),
							span_hear("You hear welding."))
			log_game("[key_name(user)] [welded ? "welded":"unwelded"] closet [src] with [W] at [AREACOORD(src)]")
			update_appearance()

	else if (can_install_electronics && istype(W, /obj/item/electronics/airlock)\
			&& !secure && !electronics && !locked && (welded || !can_weld_shut) && !broken)
		user.visible_message(span_notice("[user] installs the electronics into the [src]."),\
			span_notice("You start to install electronics into the [src]..."))

		if (!do_after(user, src, 4 SECONDS))
			return ITEM_INTERACT_BLOCKING

		if (electronics || secure)
			return ITEM_INTERACT_BLOCKING

		if (!user.transferItemToLoc(W, src))
			return ITEM_INTERACT_BLOCKING

		W.moveToNullspace()
		to_chat(user, span_notice("You install the electronics."))
		electronics = W
		if (electronics.one_access)
			req_one_access = electronics.accesses
		else
			req_access = electronics.accesses

		secure = TRUE
		update_appearance()

	else if (can_install_electronics && W.tool_behaviour == TOOL_SCREWDRIVER\
			&& (secure || electronics) && !locked && (welded || !can_weld_shut))
		user.visible_message(span_notice("[user] begins to remove the electronics from the [src]."),\
			span_notice("You begin to remove the electronics from the [src]..."))

		var/had_electronics = !!electronics
		var/was_secure = secure
		if (!do_after(user, src, 4 SECONDS))
			return ITEM_INTERACT_BLOCKING

		if ((had_electronics && !electronics) || (was_secure && !secure))
			return ITEM_INTERACT_BLOCKING

		var/obj/item/electronics/airlock/electronics_ref
		if (!electronics)
			electronics_ref = new /obj/item/electronics/airlock(loc)
			gen_access()
			if (req_one_access.len)
				electronics_ref.one_access = 1
				electronics_ref.accesses = req_one_access
			else
				electronics_ref.accesses = req_access
		else
			electronics_ref = electronics
			electronics = null
			electronics_ref.forceMove(drop_location())
		secure = FALSE
		update_appearance()

	else
		var/item_is_id = W.GetID()
		if(!item_is_id)
			return NONE

		if(item_is_id || !toggle(user))
			togglelock(user)

/obj/structure/closet/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!anchorable)
		balloon_alert(user, "no anchor bolts!")
		return TRUE
	if(isinspace() && !anchored) // We want to prevent anchoring a locker in space, but we should still be able to unanchor it there
		balloon_alert(user, "nothing to anchor to!")
		return TRUE
	set_anchored(!anchored)
	tool.play_tool_sound(src, 75)
	user.balloon_alert_to_viewers("[anchored ? "anchored" : "unanchored"]")
	return TRUE

/obj/structure/closet/proc/after_weld(weld_state)
	return

/obj/structure/closet/MouseDroppedOn(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated() || user.body_position == LYING_DOWN)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = 0
	if(isliving(O))
		actuallyismob = 1
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	var/list/targets = list(O, src)
	add_fingerprint(user)
	user.visible_message(span_warning("[user] [actuallyismob ? "tries to ":""]stuff [O] into [src]."), \
		span_warning("You [actuallyismob ? "try to ":""]stuff [O] into [src]."), \
		span_hear("You hear clanging."))
	if(actuallyismob)
		if(do_after(user, targets, 40))
			user.visible_message(span_notice("[user] stuffs [O] into [src]."), \
				span_notice("You stuff [O] into [src]."), \
				span_hear("You hear a loud metal bang."))
			var/mob/living/L = O
			if(!issilicon(L))
				L.Paralyze(40)
			if(istype(src, /obj/structure/closet/supplypod/extractionpod))
				O.forceMove(src)
			else
				O.forceMove(T)
				close()
	else
		O.forceMove(T)
	return 1

/obj/structure/closet/relaymove(mob/living/user, direction)
	if(user.stat || !isturf(loc))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	container_resist_act(user)


/obj/structure/closet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.body_position == LYING_DOWN && get_dist(src, user) > 0)
		return

	if(!toggle(user))
		togglelock(user)


/obj/structure/closet/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

/obj/structure/closet/attack_robot_secondary(mob/user, list/modifiers)
	if(!user.Adjacent(src))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	if(attack_hand(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/closet/verb/verb_toggleopen()
	set src in view(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canUseTopic(src, USE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr) || issilicon(usr) || isdrone(usr))
		return toggle(usr)
	else
		to_chat(usr, span_warning("This mob type can't use this verb."))

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/leaving, direction)
	open()
	if(leaving.loc == src)
		return FALSE
	return TRUE

/obj/structure/closet/container_resist_act(mob/living/user)
	if(isstructure(loc))
		relay_container_resist_act(user, loc)
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist_act(user, src)
		return
	if(!welded && !locked)
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_warning("[src] begins to shake violently!"), \
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear banging from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(span_danger("[user] successfully broke out of [src]!"),
							span_notice("You successfully break out of [src]!"))
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to break out of [src]!"))

/obj/structure/closet/relay_container_resist_act(mob/living/user, obj/container)
	container.container_resist_act()


/obj/structure/closet/proc/bust_open()
	SIGNAL_HANDLER
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open()

/obj/structure/closet/attack_hand_secondary(mob/user, modifiers)
	. = ..()

	if(!user.canUseTopic(src, USE_CLOSE) || !isturf(loc))
		return

	if(!opened && secure)
		togglelock(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/closet/proc/togglelock(mob/living/user, silent)
	if(secure && !broken)
		if(allowed(user))
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message(span_notice("[user] [locked ? null : "un"]locks [src]."),
							span_notice("You [locked ? null : "un"]lock [src]."))
			playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
			update_appearance()
		else if(!silent)
			to_chat(user, span_alert("Access Denied."))
	else if(secure && broken)
		to_chat(user, span_warning("\The [src] is broken!"))

/obj/structure/closet/emag_act(mob/user)
	if(secure && !broken)
		if(user)
			user.visible_message(span_warning("Sparks fly from [src]!"),
							span_warning("You scramble [src]'s lock, breaking it open!"),
							span_hear("You hear a faint electrical spark."))
		playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		broken = TRUE
		locked = FALSE
		update_appearance()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/structure/closet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in src)
			O.emp_act(severity)
	if(secure && !broken && !(. & EMP_PROTECT_SELF))
		if(prob(50 / severity))
			locked = !locked
			update_appearance()
		if(prob(20 / severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(SSid_access.get_access_for_group(list(/datum/access_group/station/all)))

/obj/structure/closet/singularity_act()
	dump_contents()
	..()

/obj/structure/closet/AllowDrop()
	return TRUE

/obj/structure/closet/proc/locker_carbon(datum/source, mob/living/carbon/shover, mob/living/carbon/target, shove_blocked)
	SIGNAL_HANDLER
	if(!opened && (locked || welded)) //Yes this could be less code, no I don't care
		return
	if(!opened && !shove_blocked)
		return
	var/was_opened = opened
	if(!toggle())
		return
	if(was_opened)
		target.forceMove(src)
	else
		target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
	update_icon()
	target.visible_message(span_danger("[shover.name] shoves [target.name] into \the [src]!"),
		span_userdanger("You're shoved into \the [src] by [target.name]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_danger("You shove [target.name] into \the [src]!"))
	log_combat(src, target, "shoved", "into [src] (locker/crate)")
	return COMSIG_CARBON_SHOVE_HANDLED

#undef LOCKER_FULL
