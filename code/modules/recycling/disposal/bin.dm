// Disposal bin and Delivery chute.

#define SEND_PRESSURE (0.05*ONE_ATMOSPHERE)

TYPEINFO_DEF(/obj/machinery/disposal)
	default_armor = list(BLUNT = 25, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 90, ACID = 30)

/obj/machinery/disposal
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	density = TRUE
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON

	var/datum/gas_mixture/air_contents // internal reservoir
	var/full_pressure = FALSE
	var/pressure_charging = TRUE
	var/flush = 0 // true if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null // the attached pipe trunk
	var/flushing = 0 // true if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //this var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0
	var/obj/structure/disposalconstruct/stored
	// create a new disposal
	// find the attached trunk (if present) and init gas resvr.

/obj/machinery/disposal/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(make_from)
		setDir(make_from.dir)
		make_from.moveToNullspace()
		stored = make_from
		pressure_charging = FALSE // newly built disposal bins start with pump off
	else
		stored = new /obj/structure/disposalconstruct(null, null , SOUTH , FALSE , src)

	trunk_check()

	air_contents = new /datum/gas_mixture()
	//gas.volume = 1.05 * CELLSTANDARD
	update_appearance()
	RegisterSignal(src, COMSIG_RAT_INTERACT, PROC_REF(on_rat_rummage))
	RegisterSignal(src, COMSIG_STORAGE_DUMP_CONTENT, PROC_REF(on_storage_dump))
	var/static/list/loc_connections = list(
		COMSIG_CARBON_DISARM_COLLIDE = PROC_REF(trash_carbon),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	return INITIALIZE_HINT_LATELOAD //we need turfs to have air

/obj/machinery/disposal/proc/trunk_check()
	trunk = locate() in loc
	if(!trunk)
		pressure_charging = FALSE
		flush = FALSE
	else
		if(initial(pressure_charging))
			pressure_charging = TRUE
		flush = initial(flush)
		trunk.linked = src // link the pipe trunk to self

/obj/machinery/disposal/Destroy()
	eject()
	if(trunk)
		trunk.linked = null
	return ..()

/obj/machinery/disposal/handle_atom_del(atom/A)
	if(A == stored && !QDELETED(src))
		stored = null
		deconstruct(FALSE)

/obj/machinery/disposal/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/machinery/disposal/LateInitialize()
	//this will get a copy of the air turf and take a SEND PRESSURE amount of air from it
	var/turf/L = loc
	var/datum/gas_mixture/env = new
	env.copyFrom(L.return_air())
	var/datum/gas_mixture/removed = env.remove(SEND_PRESSURE + 1)
	air_contents.merge(removed)
	trunk_check()

/obj/machinery/disposal/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE

	if((tool.item_flags & ABSTRACT))
		return NONE

	if(place_item_in_disposal(tool, user))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/machinery/disposal/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(pressure_charging || full_pressure || flush)
		return ITEM_INTERACT_BLOCKING

	panel_open = !panel_open
	tool.play_tool_sound(src)
	user.do_item_attack_animation(src, used_item = tool)
	visible_message(span_notice("[user] [panel_open ? "removes":"attachs"] the screws from the base of [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/disposal/welder_act_secondary(mob/living/user, obj/item/tool)
	if(!panel_open)
		to_chat(user, span_warning("\The [src] is secured to the floor with screws."))
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, amount=0))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You start slicing the floorweld off \the [src]..."))
	if(!tool.use_tool(src, user, 20, volume=100) && panel_open)
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You slice the floorweld off \the [src]."))
	deconstruct()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/disposal/proc/rat_rummage(mob/living/simple_animal/hostile/regalrat/king)
	king.visible_message(span_warning("[king] starts rummaging through [src]."),span_notice("You rummage through [src]..."))
	if (do_after(king, src, 2 SECONDS, interaction_key = "regalrat"))
		var/loot = rand(1,100)
		switch(loot)
			if(1 to 5)
				to_chat(king, span_notice("You find some leftover coins. More for the royal treasury!"))
				var/pickedcoin = pick(GLOB.ratking_coins)
				for(var/i = 1 to rand(1,3))
					new pickedcoin(get_turf(king))
			if(6 to 33)
				king.say(pick("Treasure!","Our precious!","Cheese!"))
				to_chat(king, span_notice("Score! You find some cheese!"))
				new /obj/item/food/cheese/wedge(get_turf(king))
			else
				var/pickedtrash = pick(GLOB.ratking_trash)
				to_chat(king, span_notice("You just find more garbage and dirt. Lovely, but beneath you now."))
				new pickedtrash(get_turf(king))

/obj/machinery/disposal/proc/place_item_in_disposal(obj/item/I, mob/user)
	if(user.transferItemToLoc(I, src))
		user.visible_message(span_notice("[user.name] places \the [I] into \the [src]."), span_notice("You place \the [I] into \the [src]."))
		return TRUE
	return FALSE

//mouse drop another mob or self
/obj/machinery/disposal/MouseDroppedOn(mob/living/target, mob/living/user)
	if(istype(target))
		stuff_mob_in(target, user)

/obj/machinery/disposal/proc/stuff_mob_in(mob/living/target, mob/living/user)
	var/ventcrawler = HAS_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(user, TRAIT_VENTCRAWLER_NUDE)
	if(!iscarbon(user) && !ventcrawler) //only carbon and ventcrawlers can climb into disposal by themselves.
		if (iscyborg(user))
			var/mob/living/silicon/robot/borg = user
			if (!borg.model || !borg.model.canDispose)
				return
		else
			return
	if(!isturf(user.loc)) //No magically doing it from inside closets
		return
	if(target.buckled || target.has_buckled_mobs())
		return
	if(target.mob_size > MOB_SIZE_HUMAN)
		to_chat(user, span_warning("[target] doesn't fit inside [src]!"))
		return
	add_fingerprint(user)
	if(user == target)
		user.visible_message(span_warning("[user] starts climbing into [src]."), span_notice("You start climbing into [src]..."))
	else
		target.visible_message(span_danger("[user] starts putting [target] into [src]."), span_userdanger("[user] starts putting you into [src]!"))
	if(do_after(user, target, 20))
		if (!loc)
			return
		target.forceMove(src)
		if(user == target)
			user.visible_message(span_warning("[user] climbs into [src]."), span_notice("You climb into [src]."))
			. = TRUE
		else
			target.visible_message(span_danger("[user] places [target] in [src]."), span_userdanger("[user] places you in [src]."))
			log_combat(user, target, "stuffed", addition="into [src]")
			target.LAssailant = WEAKREF(user)
			. = TRUE
		update_appearance()

/obj/machinery/disposal/relaymove(mob/living/user, direction)
	attempt_escape(user)

// resist to escape the bin
/obj/machinery/disposal/container_resist_act(mob/living/user)
	attempt_escape(user)

/obj/machinery/disposal/proc/attempt_escape(mob/user)
	if(flushing)
		return
	go_out(user)

// leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)
	user.forceMove(loc)
	update_appearance()

// clumsy monkeys and xenos can only pull the flush lever
/obj/machinery/disposal/attack_paw(mob/user, list/modifiers)
	if(ISADVANCEDTOOLUSER(user))
		return ..()
	if(machine_stat & BROKEN)
		return
	flush = !flush
	update_appearance()


// eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	pipe_eject(src, FALSE, FALSE)
	update_appearance()

/obj/machinery/disposal/proc/flush()
	flushing = TRUE
	flushAnimation()
	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, FALSE)
		last_sound = world.time
	sleep(5)
	if(QDELETED(src))
		return
	var/obj/structure/disposalholder/H = new(src)
	newHolderDestination(H)
	H.init(src)
	air_contents = new()
	H.start(src)
	flushing = FALSE
	flush = FALSE

/obj/machinery/disposal/proc/newHolderDestination(obj/structure/disposalholder/H)
	for(var/obj/item/delivery/O in src)
		H.tomail = TRUE
		return

/obj/machinery/disposal/proc/flushAnimation()
	z_flick("[icon_state]-flush", src)

// called when holder is expelled from a disposal
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)
	H.active = FALSE

	playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)

	pipe_eject(H)

	H.vent_gas(loc)
	qdel(H)

/obj/machinery/disposal/deconstruct(disassembled = TRUE)
	var/turf/T = loc
	if(!(flags_1 & NODECONSTRUCT_1))
		if(stored)
			stored.forceMove(T)
			src.transfer_fingerprints_to(stored)
			stored.set_anchored(FALSE)
			stored.set_density(TRUE)
			stored.update_appearance()
	for(var/atom/movable/AM in src) //out, out, darned crowbar!
		AM.forceMove(T)
	..()

//How disposal handles getting a storage dump from a storage object
/obj/machinery/disposal/proc/on_storage_dump(datum/source, obj/item/storage_source, mob/user)
	SIGNAL_HANDLER

	. = STORAGE_DUMP_HANDLED

	to_chat(user, span_notice("You dump out [storage_source] into [src]."))

	for(var/obj/item/to_dump in storage_source)
		if(to_dump.loc != storage_source)
			continue
		if(user.active_storage != storage_source && to_dump.on_found(user))
			return
		if(!storage_source.atom_storage.attempt_remove(to_dump, src, silent = TRUE))
			continue
		to_dump.pixel_x = to_dump.base_pixel_x + rand(-5, 5)
		to_dump.pixel_y = to_dump.base_pixel_y + rand(-5, 5)

// Disposal bin
// Holds items for disposal into pipe system
// Draws air from turf, gradually charges internal reservoir
// Once full (~1 atm), uses air resv to flush items into the pipes
// Automatically recharges air (unless off), will flush when ready if pre-set
// Can hold items and human size things, no other draggables

/obj/machinery/disposal/bin
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon_state = "disposal"
	zmm_flags = ZMM_MANGLE_PLANES

/obj/machinery/disposal/bin/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/storage/bag/trash) || !modifiers?[RIGHT_CLICK])
		return ..()

	var/obj/item/storage/bag/trash/T = tool

	user.visible_message("<b>[user]</b> begins dumping [T] into [src].", blind_message = span_hear("You hear a plastic bag rustling."))
	var/time_taken = 0.5 SECONDS * (1 + log(2, length(T.contents))) // Logarithmically scaling time, because linear would be kind of insane.
	if(!do_after(user, src, time_taken, DO_PUBLIC|DO_RESTRICT_CLICKING|DO_RESTRICT_USER_DIR_CHANGE, display = tool))
		return ITEM_INTERACT_BLOCKING

	T.atom_storage.remove_all(src)

	T.update_appearance()
	update_appearance()
	return ITEM_INTERACT_SUCCESS

// handle machine interaction

/obj/machinery/disposal/bin/ui_interact(mob/user, datum/tgui/ui)
	if(machine_stat & BROKEN)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisposalUnit", name)
		ui.open()

/obj/machinery/disposal/bin/ui_data(mob/user)
	var/list/data = list()
	data["flush"] = flush
	data["full_pressure"] = full_pressure
	data["pressure_charging"] = pressure_charging
	data["panel_open"] = panel_open
	data["per"] = CLAMP01(air_contents.returnPressure() / (SEND_PRESSURE))
	data["isai"] = isAI(user)
	return data

/obj/machinery/disposal/bin/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("handle-0")
			flush = FALSE
			update_appearance()
			. = TRUE

		if("handle-1")
			if(!panel_open)
				flush = TRUE
				update_appearance()
			. = TRUE

		if("pump-0")
			if(pressure_charging)
				pressure_charging = FALSE
				update_appearance()
			. = TRUE

		if("pump-1")
			if(!pressure_charging)
				pressure_charging = TRUE
				update_appearance()
			. = TRUE

		if("eject")
			eject()
			. = TRUE

	if(.)
		usr.animate_interact(src)


/obj/machinery/disposal/bin/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && AM.CanEnterDisposals())
		if(prob(75))
			AM.forceMove(src)
			visible_message(span_notice("[AM] lands in [src]."))
			update_appearance()
		else
			visible_message(span_warning("[AM] bounces off of [src]'s rim."))
			return ..()
	else
		return ..()

/obj/machinery/disposal/bin/flush()
	..()
	full_pressure = FALSE
	pressure_charging = TRUE
	update_appearance()

/obj/machinery/disposal/bin/update_appearance(updates)
	. = ..()
	if((machine_stat & (BROKEN|NOPOWER)) || panel_open)
		luminosity = 0
		return
	luminosity = 1

/obj/machinery/disposal/bin/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		return

	//flush handle
	if(flush)
		. += "dispover-handle"

	//only handle is shown if no power
	if(machine_stat & NOPOWER || panel_open)
		return

	//check for items in disposal - occupied light
	if(contents.len > 0)
		. += "dispover-full"
		. += emissive_appearance(icon, "dispover-full", alpha = 90)

	//charging and ready light
	if(pressure_charging)
		. += "dispover-charge"
		. += emissive_appearance(icon, "dispover-charge-glow", alpha = 90)
	else if(full_pressure)
		. += "dispover-ready"
		. += emissive_appearance(icon, "dispover-ready-glow", alpha = 90)

/obj/machinery/disposal/bin/proc/do_flush()
	set waitfor = FALSE
	flush()

//timed process
//charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/bin/process(delta_time)
	if(machine_stat & BROKEN) //nothing can happen if broken
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(contents.len)
			if(full_pressure)
				do_flush()
		flush_count = 0

	if(flush && air_contents.returnPressure() >= SEND_PRESSURE) // flush can happen even without power
		do_flush()

	if(machine_stat & NOPOWER) // won't charge if no power
		return

	use_power(idle_power_usage) // base power usage

	if(!pressure_charging) // if off or ready, no need to charge
		return

	// otherwise charge
	use_power(idle_power_usage) // charging power usage

	var/atom/L = loc //recharging from loc turf

	var/datum/gas_mixture/env = L.unsafe_return_air() //We SAFE_ZAS_UPDATE later!
	if(!env.temperature)
		return
	var/pressure_delta = (SEND_PRESSURE*1.01) - air_contents.returnPressure()

	var/transfer_moles = 0.05 * delta_time * (pressure_delta*air_contents.volume)/(env.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	air_contents.merge(removed)
	SAFE_ZAS_UPDATE(L)

	//if full enough, switch to ready mode
	if(air_contents.returnPressure() >= SEND_PRESSURE)
		full_pressure = TRUE
		pressure_charging = FALSE
		update_appearance()
	return

/obj/machinery/disposal/bin/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

//Delivery Chute

/obj/machinery/disposal/delivery_chute
	name = "delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"
	pressure_charging = FALSE // the chute doesn't need charging and always works

/obj/machinery/disposal/delivery_chute/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()
	trunk = locate() in loc
	if(trunk)
		trunk.linked = src // link the pipe trunk to self

/obj/machinery/disposal/delivery_chute/place_item_in_disposal(obj/item/I, mob/user)
	if(!I.CanEnterDisposals())
		return FALSE

	. = ..()
	if(.)
		flush()

/obj/machinery/disposal/delivery_chute/BumpedBy(atom/movable/AM) //Go straight into the chute
	if(QDELETED(AM) || !AM.CanEnterDisposals())
		return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != loc.y+1)
				return
		if(EAST)
			if(AM.loc.x != loc.x+1)
				return
		if(SOUTH)
			if(AM.loc.y != loc.y-1)
				return
		if(WEST)
			if(AM.loc.x != loc.x-1)
				return

	if(isobj(AM))
		var/obj/O = AM
		O.forceMove(src)
	else if(ismob(AM))
		var/mob/M = AM
		if(prob(2)) // to prevent mobs being stuck in infinite loops
			to_chat(M, span_warning("You hit the edge of the chute."))
			return
		M.forceMove(src)
	flush()

/atom/movable/proc/CanEnterDisposals()
	return TRUE

/obj/projectile/CanEnterDisposals()
	return

/obj/effect/CanEnterDisposals()
	return

/obj/vehicle/sealed/mecha/CanEnterDisposals()
	return

/obj/machinery/disposal/bin/newHolderDestination(obj/structure/disposalholder/H)
	H.destinationTag = 1

/obj/machinery/disposal/delivery_chute/newHolderDestination(obj/structure/disposalholder/H)
	H.destinationTag = 1


/obj/machinery/disposal/proc/on_rat_rummage(datum/source, mob/living/simple_animal/hostile/regalrat/king)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/disposal, rat_rummage), king)

/obj/machinery/disposal/proc/trash_carbon(datum/source, mob/living/carbon/shover, mob/living/carbon/target, shove_blocked)
	SIGNAL_HANDLER
	if(!shove_blocked)
		return
	target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
	target.forceMove(src)
	target.visible_message(span_danger("[shover.name] shoves [target.name] into \the [src]!"),
		span_userdanger("You're shoved into \the [src] by [target.name]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_danger("You shove [target.name] into \the [src]!"))
	log_combat(src, target, "shoved", "into [src] (disposal bin)")
	return COMSIG_CARBON_SHOVE_HANDLED
