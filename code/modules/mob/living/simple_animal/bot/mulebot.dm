

// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

#define SIGH 0
#define ANNOYED 1
#define DELIGHT 2
#define CHIME 3

/mob/living/simple_animal/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	density = TRUE
	move_resist = MOVE_FORCE_STRONG
	animate_movement = SLIDE_STEPS
	health = 50
	maxHealth = 50
	move_delay_modifier = 3
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	combat_mode = TRUE //No swapping
	buckle_lying = 0
	mob_size = MOB_SIZE_LARGE
	buckle_prevents_pull = TRUE // No pulling loaded shit

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_CARGO)
	radio_key = /obj/item/encryptionkey/headset_cargo
	radio_channel = RADIO_CHANNEL_SUPPLY
	bot_type = MULE_BOT
	path_image_color = "#7F5200"

	/// unique identifier in case there are multiple mulebots.
	var/id

	var/base_icon = "mulebot" /// icon_state to use in update_icon_state
	var/atom/movable/load /// what we're transporting
	var/mob/living/passenger /// who's riding us
	var/turf/target /// this is turf to navigate to (location of beacon)
	var/loaddir = 0 /// this the direction to unload onto/load from
	var/home_destination = "" /// tag of home delivery beacon

	var/reached_target = TRUE ///true if already reached the target
	///Number of times retried a blocked path
	var/blockcount = 0

	var/auto_return = TRUE /// true if auto return to home beacon after unload
	var/auto_pickup = TRUE /// true if auto-pickup at beacon
	var/report_delivery = TRUE /// true if bot will announce an arrival to a location.

	var/obj/item/stock_parts/cell/cell /// Internal Powercell
	var/cell_move_power_usage = 1///How much power we use when we move.
	var/bloodiness = 0 ///If we've run over a mob, how many tiles will we leave tracks on while moving
	var/num_steps = 0 ///The amount of steps we should take until we rest for a time.



/mob/living/simple_animal/bot/mulebot/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_MOB_BOT_PRE_STEP, PROC_REF(check_pre_step))
	RegisterSignal(src, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(check_pre_step))
	RegisterSignal(src, COMSIG_MOB_BOT_STEP, PROC_REF(on_bot_step))
	RegisterSignal(src, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_bot_step))

	ADD_TRAIT(src, TRAIT_NOMOBSWAP, INNATE_TRAIT)

	if(prob(0.666) && mapload)
		new /mob/living/simple_animal/bot/mulebot/paranormal(loc)
		return INITIALIZE_HINT_QDEL
	wires = new /datum/wires/mulebot(src)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/access_template/job/cargo_trim = SSid_access.template_singletons_by_path[/datum/access_template/job/cargo_technician]
	access_card.add_access(cargo_trim.access)
	prev_access = access_card.access.Copy()

	cell = new /obj/item/stock_parts/cell/upgraded(src, 2000)

	var/static/mulebot_count = 0
	mulebot_count += 1
	set_id(suffix || id || "#[mulebot_count]")
	suffix = null
	AddElement(/datum/element/ridable, /datum/component/riding/creature/mulebot)
	diag_hud_set_mulebotcell()

/mob/living/simple_animal/bot/mulebot/handle_atom_del(atom/A)
	if(A == load)
		unload(0)
	if(A == cell)
		turn_off()
		cell = null
		diag_hud_set_mulebotcell()
	return ..()

/mob/living/simple_animal/bot/mulebot/examine(mob/user)
	. = ..()
	if(bot_cover_flags & BOT_COVER_OPEN)
		if(cell)
			. += span_notice("It has \a [cell] installed.")
			. += span_info("You can use a <b>crowbar</b> to remove it.")
		else
			. += span_notice("It has an empty compartment where a <b>power cell</b> can be installed.")
	if(load) //observer check is so we don't show the name of the ghost that's sitting on it to prevent metagaming who's ded.
		. += span_notice("\A [isobserver(load) ? "ghostly figure" : load] is on its load platform.")


/mob/living/simple_animal/bot/mulebot/Destroy()
	UnregisterSignal(src, list(COMSIG_MOB_BOT_PRE_STEP, COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_MOB_BOT_STEP, COMSIG_MOB_CLIENT_MOVED))
	unload(0)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	return ..()

/mob/living/simple_animal/bot/mulebot/get_cell()
	return cell

/mob/living/simple_animal/bot/mulebot/turn_on()
	if(!has_power())
		return
	return ..()

/// returns true if the bot is fully powered.
/mob/living/simple_animal/bot/mulebot/proc/has_power()
	return cell && cell.charge > 0 && (!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))

/mob/living/simple_animal/bot/mulebot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(bot_cover_flags & BOT_COVER_OPEN && !isAI(user))
		wires.interact(user)
		return
	if(wires.is_cut(WIRE_RX) && isAI(user))
		return

	. = ..()

/mob/living/simple_animal/bot/mulebot/proc/set_id(new_id)
	id = new_id
	if(!paicard)
		name = "[initial(name)] ([new_id])"

/mob/living/simple_animal/bot/mulebot/bot_reset()
	..()
	reached_target = FALSE

/mob/living/simple_animal/bot/mulebot/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	update_appearance()

/mob/living/simple_animal/bot/mulebot/crowbar_act(mob/living/user, obj/item/tool)
	if(!(bot_cover_flags & BOT_COVER_OPEN) || user.combat_mode)
		return
	if(!cell)
		to_chat(user, span_warning("[src] doesn't have a power cell!"))
		return ITEM_INTERACT_SUCCESS
	cell.add_fingerprint(user)
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(cell)
	else
		cell.forceMove(drop_location())
	visible_message(span_notice("[user] crowbars [cell] out from [src]."),
					span_notice("You pry [cell] out of [src]."))
	cell = null
	diag_hud_set_mulebotcell()
	return ITEM_INTERACT_SUCCESS

/mob/living/simple_animal/bot/mulebot/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stock_parts/cell) && bot_cover_flags & BOT_COVER_OPEN)
		if(cell)
			to_chat(user, span_warning("[src] already has a power cell!"))
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		cell = I
		diag_hud_set_mulebotcell()
		visible_message(span_notice("[user] inserts \a [cell] into [src]."),
						span_notice("You insert [cell] into [src]."))
		return TRUE
	else if(is_wire_tool(I) && bot_cover_flags & BOT_COVER_OPEN)
		return attack_hand(user)
	else if(load && ismob(load))  // chance to knock off rider
		if(prob(1 + I.force * 2))
			unload(0)
			user.visible_message(span_danger("[user] knocks [load] off [src] with \the [I]!"),
									span_danger("You knock [load] off [src] with \the [I]!"))
		else
			to_chat(user, span_warning("You hit [src] with \the [I] but to no effect!"))
			return ..()
	else
		return ..()

/mob/living/simple_animal/bot/mulebot/emag_act(mob/user)
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		bot_cover_flags |= BOT_COVER_EMAGGED
	if(!(bot_cover_flags & BOT_COVER_OPEN))
		bot_cover_flags ^= BOT_COVER_LOCKED
		to_chat(user, span_notice("You [bot_cover_flags & BOT_COVER_LOCKED ? "lock" : "unlock"] [src]'s controls!"))
	z_flick("[base_icon]-emagged", src)
	playsound(src, SFX_SPARKS, 100, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)

/mob/living/simple_animal/bot/mulebot/update_icon_state() //if you change the icon_state names, please make sure to update /datum/wires/mulebot/on_pulse() as well. <3
	. = ..()
	icon_state = "[base_icon][bot_mode_flags & BOT_MODE_ON ? wires.is_cut(WIRE_AVOIDANCE) : 0]"

/mob/living/simple_animal/bot/mulebot/update_overlays()
	. = ..()
	if(bot_cover_flags & BOT_COVER_OPEN)
		. += "[base_icon]-hatch"
	if(!load || ismob(load)) //mob offsets and such are handled by the riding component / buckling
		return
	var/mutable_appearance/load_overlay = mutable_appearance(load.icon, load.icon_state, layer + 0.01)
	load_overlay.pixel_y = initial(load.pixel_y) + 9
	. += load_overlay

/mob/living/simple_animal/bot/mulebot/ex_act(severity)
	unload(0)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			wires.cut_random()
			wires.cut_random()
		if(EXPLODE_LIGHT)
			wires.cut_random()


/mob/living/simple_animal/bot/mulebot/bullet_act(obj/projectile/Proj)
	. = ..()
	if(. && !QDELETED(src)) //Got hit and not blown up yet.
		if(prob(50) && !isnull(load))
			unload(0)
		if(prob(25))
			visible_message(span_danger("Something shorts out inside [src]!"))
			wires.cut_random()

/mob/living/simple_animal/bot/mulebot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mule", name)
		ui.open()

/mob/living/simple_animal/bot/mulebot/ui_data(mob/user)
	var/list/data = list()
	data["on"] = bot_mode_flags & BOT_MODE_ON
	data["locked"] = bot_cover_flags & BOT_COVER_LOCKED
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["mode"] = mode ? "[mode]" : "Ready"
	data["modeStatus"] = ""
	switch(mode)
		if(BOT_IDLE, BOT_DELIVER, BOT_GO_HOME)
			data["modeStatus"] = "good"
		if(BOT_BLOCKED, BOT_NAV, BOT_WAIT_FOR_NAV, BOT_PATHING)
			data["modeStatus"] = "average"
		if(BOT_NO_ROUTE)
			data["modeStatus"] = "bad"
	data["load"] = get_load_name()
	data["destination"] = destination ? destination : null
	data["home"] = home_destination
	data["destinations"] = GLOB.deliverybeacontags
	data["cell"] = cell ? TRUE : FALSE
	data["cellPercent"] = cell ? cell.percent() : null
	data["autoReturn"] = auto_return
	data["autoPickup"] = auto_pickup
	data["reportDelivery"] = report_delivery
	data["haspai"] = paicard ? TRUE : FALSE
	data["id"] = id
	return data

/mob/living/simple_animal/bot/mulebot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				bot_cover_flags ^= BOT_COVER_LOCKED
				. = TRUE
		if("on")
			if(bot_mode_flags & BOT_MODE_ON)
				turn_off()
			else if(bot_cover_flags & BOT_COVER_OPEN)
				to_chat(usr, span_warning("[name]'s maintenance panel is open!"))
				return
			else if(cell)
				if(!turn_on())
					to_chat(usr, span_warning("You can't switch on [src]!"))
					return
			. = TRUE
		else
			bot_control(action, usr, params) // Kill this later. // Kill PDAs in general please
			. = TRUE

/mob/living/simple_animal/bot/mulebot/bot_control(command, mob/user, list/params = list(), pda = FALSE)
	if(pda && wires.is_cut(WIRE_RX)) // MULE wireless is controlled by wires.
		return

	switch(command)
		if("stop")
			if(mode != BOT_IDLE)
				bot_reset()
		if("go")
			if(mode == BOT_IDLE)
				start()
		if("home")
			if(mode == BOT_IDLE || mode == BOT_DELIVER)
				start_home()
		if("destination")
			var/new_dest
			if(pda)
				new_dest = tgui_input_list(user, "Enter Destination", "Mulebot Settings", GLOB.deliverybeacontags, destination)
			else
				new_dest = params["value"]
			if(new_dest)
				set_destination(new_dest)
		if("setid")
			var/new_id
			if(pda)
				new_id = tgui_input_text(user, "Enter ID", "ID Assignment", id, MAX_NAME_LEN)
			else
				new_id = params["value"]
			if(new_id)
				set_id(new_id)
		if("sethome")
			var/new_home
			if(pda)
				new_home = tgui_input_list(user, "Enter Home", "Mulebot Settings", GLOB.deliverybeacontags, home_destination)
			else
				new_home = params["value"]
			if(new_home)
				home_destination = new_home
		if("unload")
			if(load && mode != BOT_HUNT)
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
		if("autoret")
			auto_return = !auto_return
		if("autopick")
			auto_pickup = !auto_pickup
		if("report")
			report_delivery = !report_delivery
		if("ejectpai")
			ejectpairemote(user)

/mob/living/simple_animal/bot/mulebot/proc/buzz(type)
	switch(type)
		if(SIGH)
			audible_message(span_hear("[src] makes a sighing buzz."))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		if(ANNOYED)
			audible_message(span_hear("[src] makes an annoyed buzzing sound."))
			playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		if(DELIGHT)
			audible_message(span_hear("[src] makes a delighted ping!"))
			playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		if(CHIME)
			audible_message(span_hear("[src] makes a chiming sound!"))
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
	z_flick("[base_icon]1", src)


// mousedrop a crate to load the bot
// can load anything if hacked
/mob/living/simple_animal/bot/mulebot/MouseDroppedOn(atom/movable/AM, mob/user)
	var/mob/living/L = user

	if (!istype(L))
		return

	if(user.incapacitated() || (istype(L) && L.body_position == LYING_DOWN))
		return

	if(!istype(AM) || isdead(AM) || iscameramob(AM) || istype(AM, /obj/effect/dummy/phased_mob))
		return

	load(AM)


// called to load a crate
/mob/living/simple_animal/bot/mulebot/proc/load(atom/movable/AM)
	if(load || AM.anchored)
		return

	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/crate = AM
	if(!istype(crate))
		if(!wires.is_cut(WIRE_LOADCHECK))
			buzz(SIGH)
			return // if not hacked, only allow crates to be loaded
		crate = null

	if(crate || isobj(AM))
		var/obj/O = AM
		if(O.has_buckled_mobs() || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

		if(crate)
			crate.close()  //make sure the crate is closed

		O.forceMove(src)

	else if(isliving(AM))
		if(!load_mob(AM)) //forceMove() is handled in buckling
			return

	load = AM
	set_mode(BOT_IDLE)
	update_appearance()

///resolves the name to display for the loaded mob. primarily needed for the paranormal subtype since we don't want to show the name of ghosts riding it.
/mob/living/simple_animal/bot/mulebot/proc/get_load_name()
	return load ? load.name : null

/mob/living/simple_animal/bot/mulebot/proc/load_mob(mob/living/M)
	can_buckle = TRUE
	if(buckle_mob(M))
		passenger = M
		load = M
		can_buckle = FALSE
		return TRUE

/mob/living/simple_animal/bot/mulebot/post_unbuckle_mob(mob/living/M)
		load = null
		return ..()

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/mob/living/simple_animal/bot/mulebot/proc/unload(dirn)
	if(QDELETED(load))
		if(load) //if our thing was qdel'd, there's likely a leftover reference. just clear it and remove the overlay. we'll let the bot keep moving around to prevent it abruptly stopping somewhere.
			load = null
			update_appearance()
		return

	set_mode(BOT_IDLE)

	var/atom/movable/cached_load = load //cache the load since unbuckling mobs clears the var.

	unbuckle_all_mobs()

	if(load) //don't have to do any of this for mobs.
		load.forceMove(loc)
		load.pixel_y = initial(load.pixel_y)
		load.layer = initial(load.layer)
		load.plane = initial(load.plane)
		load = null

	if(dirn) //move the thing to the delivery point.
		cached_load.Move(get_step(loc,dirn), dirn)

	update_appearance()

/mob/living/simple_animal/bot/mulebot/get_status_tab_items()
	. = ..()
	if(cell)
		. += "Charge Left: [cell.charge]/[cell.maxcharge]"
	else
		. += "No Cell Inserted!"
	if(load)
		. += "Current Load: [get_load_name()]"


/mob/living/simple_animal/bot/mulebot/call_bot()
	..()
	if(path && length(path))
		target = ai_waypoint //Target is the end point of the path, the waypoint set by the AI.
		destination = get_area_name(target, TRUE)
		pathset = TRUE //Indicates the AI's custom path is initialized.
		start()

/mob/living/simple_animal/bot/mulebot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			run_over(future_pancake)

	diag_hud_set_mulebotcell()

/mob/living/simple_animal/bot/mulebot/handle_automated_action()
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(!has_power())
		turn_off()
		return
	if(mode == BOT_IDLE)
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return

	var/speed = (wires.is_cut(WIRE_MOTOR1) ? 0 : 1) + (wires.is_cut(WIRE_MOTOR2) ? 0 : 2)
	if(!speed)//Devide by zero man bad
		return
	num_steps = round(10/speed) //10, 5, or 3 steps, depending on how many wires we have cut
	START_PROCESSING(SSfastprocess, src)

/mob/living/simple_animal/bot/mulebot/process()
	if(!(bot_mode_flags & BOT_MODE_ON) || client || (num_steps <= 0) || !has_power())
		return PROCESS_KILL
	num_steps--

	switch(mode)
		if(BOT_IDLE) // idle
			return

		if(BOT_DELIVER, BOT_GO_HOME, BOT_BLOCKED) // navigating to deliver,home, or blocked
			if(loc == target) // reached target
				at_target()
				return

			else if(length(path) && target) // valid path
				var/turf/next = path[1]
				reached_target = FALSE
				if(next == loc)
					path -= next
					return
				if(isturf(next))
					if(SEND_SIGNAL(src, COMSIG_MOB_BOT_PRE_STEP) & COMPONENT_MOB_BOT_BLOCK_PRE_STEP)
						return
					var/oldloc = loc
					var/moved = step_towards(src, next) // attempt to move
					if(moved && oldloc!=loc) // successful move
						SEND_SIGNAL(src, COMSIG_MOB_BOT_STEP)
						blockcount = 0
						path -= loc
						if(destination == home_destination)
							set_mode(BOT_GO_HOME)
						else
							set_mode(BOT_DELIVER)

					else // failed to move

						blockcount++
						set_mode(BOT_BLOCKED)
						if(blockcount == 3)
							buzz(ANNOYED)

						if(blockcount > 10) // attempt 10 times before recomputing
							// find new path excluding blocked turf
							buzz(SIGH)
							set_mode(BOT_WAIT_FOR_NAV)
							blockcount = 0
							addtimer(CALLBACK(src, PROC_REF(process_blocked), next), 2 SECONDS)
							return
						return
				else
					buzz(ANNOYED)
					set_mode(BOT_NAV)
					return
			else
				set_mode(BOT_NAV)
				return

		if(BOT_NAV) // calculate new path
			set_mode(BOT_WAIT_FOR_NAV)
			INVOKE_ASYNC(src, PROC_REF(process_nav))

/mob/living/simple_animal/bot/mulebot/proc/process_blocked(turf/next)
	calc_path(avoid=next)
	if(length(path))
		buzz(DELIGHT)
	set_mode(BOT_BLOCKED)

/mob/living/simple_animal/bot/mulebot/proc/process_nav()
	calc_path()

	if(length(path))
		blockcount = 0
		set_mode(BOT_BLOCKED)
		buzz(DELIGHT)

	else
		buzz(SIGH)

		set_mode(BOT_NO_ROUTE)

// calculates a path to the current destination
// given an optional turf to avoid
/mob/living/simple_animal/bot/mulebot/calc_path(turf/avoid = null)
	path = jps_path_to(src, target, max_distance=250, access = access_card?.GetAccess(), exclude=avoid, diagonal_handling=DIAGONAL_REMOVE_ALL)

// sets the current destination
// signals all beacons matching the delivery code
// beacons will return a signal giving their locations
/mob/living/simple_animal/bot/mulebot/proc/set_destination(new_dest)
	new_destination = new_dest
	get_nav()

// starts bot moving to current destination
/mob/living/simple_animal/bot/mulebot/proc/start()
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(destination == home_destination)
		set_mode(BOT_GO_HOME)
	else
		set_mode(BOT_DELIVER)
	get_nav()

// starts bot moving to home
// sends a beacon query to find
/mob/living/simple_animal/bot/mulebot/proc/start_home()
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	INVOKE_ASYNC(src, PROC_REF(do_start_home))

/mob/living/simple_animal/bot/mulebot/proc/do_start_home()
	set_destination(home_destination)
	set_mode(BOT_BLOCKED)

// called when bot reaches current target
/mob/living/simple_animal/bot/mulebot/proc/at_target()
	if(!reached_target)
		radio_channel = RADIO_CHANNEL_SUPPLY //Supply channel
		buzz(CHIME)
		reached_target = TRUE

		if(pathset) //The AI called us here, so notify it of our arrival.
			loaddir = dir //The MULE will attempt to load a crate in whatever direction the MULE is "facing".
			if(calling_ai)
				to_chat(calling_ai, span_notice("[icon2html(src, calling_ai)] [src] wirelessly plays a chiming sound!"))
				calling_ai.playsound_local(calling_ai, 'sound/machines/chime.ogg', 40, FALSE)
				calling_ai = null
				radio_channel = RADIO_CHANNEL_AI_PRIVATE //Report on AI Private instead if the AI is controlling us.

		if(load) // if loaded, unload at target
			if(report_delivery)
				speak("Destination <b>[destination]</b> reached. Unloading [load].",radio_channel)
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup) // find a crate
				var/atom/movable/AM
				if(wires.is_cut(WIRE_LOADCHECK)) // if hacked, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else // otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM?.Adjacent(src))
					load(AM)
					if(report_delivery)
						speak("Now loading [load] at <b>[get_area_name(src)]</b>.", radio_channel)
		// whatever happened, check to see if we return home

		if(auto_return && home_destination && destination != home_destination)
			// auto return set and not at home already
			start_home()
			set_mode(BOT_BLOCKED)
		else
			bot_reset() // otherwise go idle


/mob/living/simple_animal/bot/mulebot/MobBump(mob/M) // called when the bot bumps into a mob
	if(paicard || !isliving(M)) //if there's a PAIcard controlling the bot, they aren't allowed to harm folks.
		return ..()
	var/mob/living/L = M
	if(wires.is_cut(WIRE_AVOIDANCE)) // usually just bumps, but if the avoidance wire is cut, knocks them over.
		if(iscyborg(L))
			visible_message(span_danger("[src] bumps into [L]!"))
		else if(L.Knockdown(8 SECONDS))
			log_combat(src, L, "knocked down")
			visible_message(span_danger("[src] knocks over [L]!"))
	return ..()

// when mulebot is in the same loc
/mob/living/simple_animal/bot/mulebot/proc/run_over(mob/living/carbon/human/H)
	log_combat(src, H, "run over", null, "(DAMTYPE: [uppertext(BRUTE)])")
	H.visible_message(span_danger("[src] drives over [H]!"), \
					span_userdanger("[src] drives over you!"))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_HEAD, run_armor_check(BODY_ZONE_HEAD, BLUNT))
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_CHEST, run_armor_check(BODY_ZONE_CHEST, BLUNT))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_LEG, run_armor_check(BODY_ZONE_L_LEG, BLUNT))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_LEG, run_armor_check(BODY_ZONE_R_LEG, BLUNT))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_ARM, run_armor_check(BODY_ZONE_L_ARM, BLUNT))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_ARM, run_armor_check(BODY_ZONE_R_ARM, BLUNT))

	var/turf/T = get_turf(src)
	T.add_mob_blood(H)

	var/list/blood_dna = H.get_blood_dna_list()
	add_blood_DNA(blood_dna)
	bloodiness += 4

// player on mulebot attempted to move
/mob/living/simple_animal/bot/mulebot/relaymove(mob/living/user, direction)
	if(user.incapacitated())
		return
	if(load == user)
		unload(0)


//Update navigation data. Called when commanded to deliver, return home, or a route update is needed...
/mob/living/simple_animal/bot/mulebot/proc/get_nav()
	if(!(bot_mode_flags & BOT_MODE_ON) || wires.is_cut(WIRE_BEACON))
		return

	for(var/obj/machinery/navbeacon/NB in GLOB.deliverybeacons)
		if(NB.location == new_destination) // if the beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			target = NB.loc
			var/direction = NB.dir // this will be the load/unload dir
			if(direction)
				loaddir = text2num(direction)
			else
				loaddir = 0
			if(destination) // No need to calculate a path if you do not have a destination set!
				calc_path()

/mob/living/simple_animal/bot/mulebot/emp_act(severity)
	. = ..()
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)


/mob/living/simple_animal/bot/mulebot/explode()
	var/atom/Tsec = drop_location()

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if(cell)
		cell.forceMove(Tsec)
		cell.update_appearance()
		cell = null

	new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/mob/living/simple_animal/bot/mulebot/remove_air(amount) //To prevent riders suffocating
	return loc ? loc.remove_air(amount) : null

/mob/living/simple_animal/bot/mulebot/execute_resist()
	. = ..()
	if(load)
		unload()

/mob/living/simple_animal/bot/mulebot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!can_unarmed_attack())
		return
	if(isturf(A) && isturf(loc) && loc.Adjacent(A) && load)
		unload(get_dir(loc, A))
	else
		return ..()

/mob/living/simple_animal/bot/mulebot/insertpai(mob/user, obj/item/paicard/card)
	. = ..()
	if(.)
		visible_message(span_notice("[src]'s safeties are locked on."))

/// Checks whether the bot can complete a step_towards, checking whether the bot is on and has the charge to do the move. Returns COMPONENT_MOB_BOT_CANCELSTEP if the bot should not step.
/mob/living/simple_animal/bot/mulebot/proc/check_pre_step(datum/source)
	SIGNAL_HANDLER

	if(!(bot_mode_flags & BOT_MODE_ON))
		return COMPONENT_MOB_BOT_BLOCK_PRE_STEP

	if((cell && (cell.charge < cell_move_power_usage)) || !has_power())
		turn_off()
		return COMPONENT_MOB_BOT_BLOCK_PRE_STEP

/// Uses power from the cell when the bot steps.
/mob/living/simple_animal/bot/mulebot/proc/on_bot_step(datum/source)
	SIGNAL_HANDLER

	cell?.use(cell_move_power_usage)

/mob/living/simple_animal/bot/mulebot/paranormal//allows ghosts only unless hacked to actually be useful
	name = "\improper GHOULbot"
	desc = "A rather ghastly looking... Multiple Utility Load Effector bot? It only seems to accept paranormal forces, and for this reason is fucking useless."
	icon_state = "paranormalmulebot0"
	base_icon = "paranormalmulebot"


/mob/living/simple_animal/bot/mulebot/paranormal/MouseDroppedOn(atom/movable/AM, mob/user)
	var/mob/living/L = user

	if(user.incapacitated() || (istype(L) && L.body_position == LYING_DOWN))
		return

	if(!istype(AM) || iscameramob(AM) || istype(AM, /obj/effect/dummy/phased_mob)) //allows ghosts!
		return

	load(AM)

/mob/living/simple_animal/bot/mulebot/paranormal/load(atom/movable/AM)
	if(load || AM.anchored)
		return

	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	if(isobserver(AM))
		visible_message(span_warning("A ghostly figure appears on [src]!"))
		RegisterSignal(AM, COMSIG_MOVABLE_MOVED, PROC_REF(ghostmoved))
		AM.forceMove(src)

	else if(!wires.is_cut(WIRE_LOADCHECK))
		buzz(SIGH)
		return // if not hacked, only allow ghosts to be loaded

	else if(isobj(AM))
		var/obj/O = AM
		if(O.has_buckled_mobs() || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

		if(istype(O, /obj/structure/closet/crate))
			var/obj/structure/closet/crate/crate = O
			crate.close() //make sure it's closed

		O.forceMove(src)

	else if(isliving(AM))
		if(!load_mob(AM)) //buckling is handled in forceMove()
			return

	load = AM
	set_mode(BOT_IDLE)
	update_appearance()

/mob/living/simple_animal/bot/mulebot/paranormal/update_overlays()
	. = ..()
	if(!isobserver(load))
		return
	var/mutable_appearance/ghost_overlay = mutable_appearance('icons/mob/mob.dmi', "ghost", layer + 0.01) //use a generic ghost icon, otherwise you can metagame who's dead if they have a custom ghost set
	ghost_overlay.pixel_y = 12
	. += ghost_overlay

/mob/living/simple_animal/bot/mulebot/paranormal/get_load_name() //Don't reveal the name of ghosts so we can't metagame who died and all that.
	. = ..()
	if(. && isobserver(load))
		return "Unknown"

/mob/living/simple_animal/bot/mulebot/paranormal/proc/ghostmoved()
	SIGNAL_HANDLER
	visible_message(span_notice("The ghostly figure vanishes..."))
	UnregisterSignal(load, COMSIG_MOVABLE_MOVED)
	unload(0)

#undef SIGH
#undef ANNOYED
#undef DELIGHT
#undef CHIME
