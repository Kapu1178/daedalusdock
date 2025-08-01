/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define DEVIATION_NONE 0
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define DEVIATION_PARTIAL 1
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define DEVIATION_FULL 2

TYPEINFO_DEF(/obj/item/assembly/flash)
	default_materials = list(/datum/material/iron = 300, /datum/material/glass = 300)

/obj/item/assembly/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon_state = "flash"
	inhand_icon_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

	throwforce = 2

	w_class = WEIGHT_CLASS_TINY
	light_system = OVERLAY_LIGHT //Used as a flash here.
	light_outer_range = FLASH_LIGHT_RANGE
	light_color = COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	light_on = FALSE

	has_combat_mode_interaction = TRUE

	/// Whether we currently have the flashing overlay.
	var/flashing = FALSE
	/// The overlay we use for flashing.
	var/flashing_overlay = "flash-f"
	var/times_used = 0 //Number of times it's been used.
	var/burnt_out = FALSE     //Is the flash burnt out?
	var/burnout_resistance = 0
	var/last_used = 0 //last world.time it was used.
	var/cooldown = 0
	var/last_trigger = 0 //Last time it was successfully triggered.
	var/flash_sound = 'sound/weapons/flash.ogg' //For custom sounds when the flash is used.

/obj/item/assembly/flash/suicide_act(mob/living/user)
	if(burnt_out)
		user.visible_message(span_suicide("[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but it's burnt out!"))
		return SHAME
	else if(user.is_blind())
		user.visible_message(span_suicide("[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but [user.p_theyre()] blind!"))
		return SHAME
	user.visible_message(span_suicide("[user] raises \the [src] up to [user.p_their()] eyes and activates it! It looks like [user.p_theyre()] trying to commit suicide!"))
	interact_with_atom(user,user)
	return FIRELOSS

/obj/item/assembly/flash/update_icon(updates=ALL, flash = FALSE)
	inhand_icon_state = "[burnt_out ? "flashtool_burnt" : "[initial(inhand_icon_state)]"]"
	flashing = flash
	. = ..()
	if(flash)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 5)
	holder?.update_icon(updates)

/obj/item/assembly/flash/update_overlays()
	attached_overlays = list()
	. = ..()
	if(burnt_out)
		. += "flashburnt"
		attached_overlays += "flashburnt"
	if(flashing)
		. += flashing_overlay
		attached_overlays += flashing_overlay

/obj/item/assembly/flash/update_name()
	name = "[burnt_out ? "burnt-out [initial(name)]" : "[initial(name)]"]"
	return ..()

/obj/item/assembly/flash/proc/clown_check(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, confusion_duration = 15 SECONDS, targeted = FALSE)
		return FALSE
	return TRUE

/obj/item/assembly/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	if(!burnt_out)
		burnt_out = TRUE
		loc?.visible_message(span_danger("[src] burns out!"),span_userdanger("[src] burns out!"))
		update_appearance()

/obj/item/assembly/flash/proc/flash_recharge(interval = 10)
	var/deciseconds_passed = world.time - last_used
	for(var/seconds = deciseconds_passed / 10, seconds >= interval, seconds -= interval) //get 1 charge every interval
		times_used--
	last_used = world.time
	times_used = max(0, times_used) //sanity
	if(max(0, prob(times_used * 3) - burnout_resistance)) //The more often it's used in a short span of time the more likely it will burn out
		burn_out()
		return FALSE
	return TRUE

//BYPASS CHECKS ALSO PREVENTS BURNOUT!
/obj/item/assembly/flash/proc/AOE_flash(bypass_checks = FALSE, range = 3, confusion_duration = 5 SECONDS, targeted = FALSE, mob/user)
	if(!bypass_checks && !try_use_flash())
		return FALSE
	var/list/mob/targets = get_flash_targets(get_turf(src), range, FALSE)
	if(user)
		targets -= user
		to_chat(user, span_danger("[src] emits a blinding light!"))
	for(var/mob/living/carbon/nearby_carbon in targets)
		flash_carbon(nearby_carbon, user, confusion_duration = confusion_duration, targeted = targeted, generic_message = TRUE)
	return TRUE

/obj/item/assembly/flash/proc/get_flash_targets(atom/target_loc, range = 3, override_vision_checks = FALSE)
	if(!target_loc)
		target_loc = loc
	if(override_vision_checks)
		return get_hearers_in_view(range, get_turf(target_loc))
	if(isturf(target_loc) || (ismob(target_loc) && isturf(target_loc.loc)))
		return viewers(range, get_turf(target_loc))
	else
		return typecache_filter_list(target_loc.get_all_contents(), GLOB.typecache_living)

/obj/item/assembly/flash/proc/try_use_flash(mob/user = null)
	if(burnt_out || (world.time < last_trigger + cooldown))
		return FALSE
	last_trigger = world.time
	playsound(src, flash_sound, 100, TRUE)
	set_light_on(TRUE)
	addtimer(CALLBACK(src, PROC_REF(flash_end)), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)
	times_used++
	if(!flash_recharge())
		return FALSE
	update_icon(ALL, TRUE)
	update_name(ALL) //so if burnt_out was somehow reverted to 0 the name changes back to flash
	if(user && !clown_check(user))
		return FALSE
	return TRUE


/obj/item/assembly/flash/proc/flash_end()
	set_light_on(FALSE)

/**
 * Handles actual flashing part of the attack
 *
 * This proc is awful in every sense of the way, someone should definately refactor this whole code.
 * Arguments:
 * * M - Victim
 * * user - Attacker
 * * confusion_duration - handles the amount of confusion it gives you
 * * targeted - determines if it was aoe or targeted
 * * generic_message - checks if it should display default message.
 */
/obj/item/assembly/flash/proc/flash_carbon(mob/living/carbon/flashed, mob/user, confusion_duration = 15 SECONDS, targeted = TRUE, generic_message = FALSE)
	if(!istype(flashed))
		return
	if(user)
		log_combat(user, flashed, "[targeted? "flashed(targeted)" : "flashed(AOE)"]", src)
	else //caused by emp/remote signal
		flashed.log_message("was [targeted? "flashed(targeted)" : "flashed(AOE)"]",LOG_ATTACK)

	if(generic_message && flashed != user)
		to_chat(flashed, span_danger("[src] emits a blinding light!"))

	var/deviation = calculate_deviation(flashed, user || src)

	var/datum/antagonist/rev/head/converter = user?.mind?.has_antag_datum(/datum/antagonist/rev/head)

	//If you face away from someone they shouldnt notice any effects.
	if(deviation == DEVIATION_FULL && !converter)
		return


	if(targeted)
		if(flashed.flash_act(1, 1))
			// Special check for if we're a revhead. Special cases to attempt conversion.
			if(converter)
				// Did we try to flash them from behind?
				if(deviation == DEVIATION_FULL)
					// Headrevs can use a tacticool leaning technique so that they don't have to worry about facing for their conversions.
					to_chat(user, span_notice("You use the tacticool tech, lean over the shoulder technique to blind [flashed] with a flash!"))
					deviation = DEVIATION_PARTIAL
				// Convert them. Terribly.
				terrible_conversion_proc(flashed, user)
				visible_message(span_danger("[user] blinds [flashed] with the flash!"), span_userdanger("[user] blinds you with the flash!"))
			//easy way to make sure that you can only long stun someone who is facing in your direction
			flashed.Disorient((7 SECONDS * (1-(deviation*0.5))), 90 * (1-(deviation*0.5)), paralyze = 4 SECONDS)
		else if(user)
			visible_message(span_warning("[user] fails to blind [flashed] with the flash!"), span_danger("[user] fails to blind you with the flash!"))
		else
			to_chat(flashed, span_danger("[src] fails to blind you!"))

	else
		flashed.Disorient(7 SECONDS * (1-(deviation*0.5)), 90 * (1-(deviation*0.5)), paralyze = 4 SECONDS)

/**
 * Handles the directionality of the attack
 *
 * Returns the amount of 'deviation', 0 being facing eachother, 1 being sideways, 2 being facing away from eachother.
 * Arguments:
 * * victim - Victim
 * * attacker - Attacker
 */
/obj/item/assembly/flash/proc/calculate_deviation(mob/victim, atom/attacker)
	// Tactical combat emote-spinning should not counter intended gameplay mechanics.
	// This trumps same-loc checks to discourage floor spinning in general to counter flashes.
	// In short, combat spinning is silly and you should feel silly for doing it.
	if(victim.flags_1 & IS_SPINNING_1)
		return DEVIATION_NONE

	if(HAS_TRAIT(victim, TRAIT_FLASH_SENSITIVE)) //If your eyes are sensitive and can be flashed from any direction.
		return DEVIATION_NONE

	// Are they on the same tile? We'll return partial deviation. This may be someone flashing while lying down
	// or flashing someone they're stood on the same turf as, or a borg flashing someone buckled to them.
	if(victim.loc == attacker.loc)
		return DEVIATION_PARTIAL

	// If the victim was looking at the attacker, this is the direction they'd have to be facing.
	var/victim_to_attacker = get_dir(victim, attacker)
	// The victim's dir is necessarily a cardinal value.
	var/victim_dir = victim.dir

	// - - -
	// - V - Victim facing south
	// # # #
	// Attacker within 45 degrees of where the victim is facing.
	if(victim_dir & victim_to_attacker)
		return DEVIATION_NONE

	// # # #
	// - V - Victim facing south
	// - - -
	// Attacker at 135 or more degrees of where the victim is facing.
	if(victim_dir & REVERSE_DIR(victim_to_attacker))
		return DEVIATION_FULL

	// - - -
	// # V # Victim facing south
	// - - -
	// Attacker lateral to the victim.
	return DEVIATION_PARTIAL

/obj/item/assembly/flash/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ismob(interacting_with))
		return NONE

	if(!try_use_flash(user))
		return NONE

	var/mob/living/M = interacting_with
	M.do_attack_animation(interacting_with, do_hurt = FALSE)

	if(iscarbon(M))
		flash_carbon(M, user, confusion_duration = 5 SECONDS, targeted = TRUE)
		return ITEM_INTERACT_SUCCESS

	if(issilicon(M))
		var/mob/living/silicon/robot/flashed_borgo = M
		log_combat(user, flashed_borgo, "flashed", src)
		update_icon(ALL, TRUE)
		if(!flashed_borgo.flash_act(affect_silicon = TRUE))
			user.visible_message(span_warning("[user] fails to blind [flashed_borgo] with the flash!"), span_warning("You fail to blind [flashed_borgo] with the flash!"))
			return ITEM_INTERACT_SUCCESS

		flashed_borgo.Disorient(70, paralyze = rand(80, 120), stack_status = FALSE)
		user.visible_message(span_warning("[user] overloads [flashed_borgo]'s sensors with the flash!"), span_danger("You overload [flashed_borgo]'s sensors with the flash!"))
		return ITEM_INTERACT_SUCCESS

	user.visible_message(span_warning("[user] fails to blind [M] with the flash!"), span_warning("You fail to blind [M] with the flash!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/assembly/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(holder)
		return FALSE
	if(AOE_flash(user = user))
		user.changeNext_move(CLICK_CD_MELEE)


/obj/item/assembly/flash/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!try_use_flash())
		return
	AOE_flash()
	burn_out()

/obj/item/assembly/flash/activate()//AOE flash on signal received
	if(!..())
		return
	AOE_flash()

/**
 * Converts the victim to revs
 *
 * Arguments:
 * * victim - Victim
 * * aggressor - Attacker
 */
/obj/item/assembly/flash/proc/terrible_conversion_proc(mob/living/carbon/victim, mob/aggressor)
	if(!istype(victim) || victim.stat == DEAD)
		return
	if(!aggressor.mind)
		return
	if(!victim.client)
		to_chat(aggressor, span_warning("This mind is so vacant that it is not susceptible to influence!"))
		return
	if(victim.stat != CONSCIOUS)
		to_chat(aggressor, span_warning("They must be conscious before you can convert [victim.p_them()]!"))
		return
	if(!victim.mind || victim.mind.has_antag_datum(/datum/antagonist/rev) || victim.mind.has_antag_datum(/datum/antagonist/rev/head))
		return

	//If this proc fires the mob must be a revhead
	var/datum/antagonist/rev/head/converter = aggressor.mind.has_antag_datum(/datum/antagonist/rev/head)
	if(converter.add_revolutionary(victim.mind))
		if(prob(1) || SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
			victim.say("You son of a bitch! I'm in.", forced = "That son of a bitch! They're in.")
		times_used -- //Flashes less likely to burn out for headrevs when used for conversion
	else
		to_chat(aggressor, span_warning("[victim.p_they(TRUE)] [victim.p_are()] unwilling to revolt!"))

/obj/item/assembly/flash/cyborg

/obj/item/assembly/flash/cyborg/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/assembly/flash/cyborg/attack_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/assembly/flash/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/flash/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return

///Camera flash

/obj/item/assembly/flash/camera
	name = "camera"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	inhand_icon_state = "camera"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	slot_flags = ITEM_SLOT_NECK
	pickup_sound = null //override pickup and drop sounds so it behaves more like a real camera.
	drop_sound = null
	flash_sound = 'sound/items/polaroid1.ogg'
	var/max_charges = 5
	var/current_charges = 5
	var/list/charge_timers = list()
	var/charge_time = 30 SECONDS

/obj/item/assembly/flash/camera/burn_out()
	return //use self charging system instead

/obj/item/assembly/flash/camera/attack_self(mob/living/carbon/user, flag = 0)
	if(use_charge(user))
		. = ..()

/obj/item/assembly/flash/camera/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	if(!use_charge(user))
		return NONE

	return ..()

/obj/item/assembly/flash/camera/proc/use_charge(mob/user)
	if(current_charges)
		current_charges--
		to_chat(user, span_notice("You use [src]. It now has [current_charges] charge\s remaining."))
		charge_timers.Add(addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_STOPPABLE))
		return TRUE
	else
		to_chat(user, span_warning("[src] is recharging."))

/obj/item/assembly/flash/camera/proc/recharge(mob/user)
	current_charges = min(current_charges+1, max_charges)
	charge_timers.Remove(charge_timers[1])

/obj/item/assembly/flash/camera/examine(mob/user)
	. = ..()
	. += span_notice("It has [current_charges] charge\s remaining.")
	if (length(charge_timers))
		. += span_boldnotice("A small display on the screen reads:")
	for (var/i in 1 to length(charge_timers))
		var/timeleft = timeleft(charge_timers[i])
		var/loadingbar = num2loadingbar(timeleft/charge_time)
		. += span_boldnotice("CHARGE #[i]: [loadingbar] ([timeleft*0.1]s)")

//Memorizer

/obj/item/assembly/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer"
	inhand_icon_state = "nullrod"

/obj/item/assembly/flash/handheld //this is now the regular pocket flashes

/obj/item/assembly/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	var/flashcd = 20
	var/overheat = 0
	//Wearef to our arm
	var/datum/weakref/arm

/obj/item/assembly/flash/armimplant/burn_out()
	var/obj/item/organ/cyberimp/arm/flash/real_arm = arm.resolve()
	if(real_arm?.owner)
		to_chat(real_arm.owner, span_warning("Your photon projector implant overheats and deactivates!"))
		real_arm.Retract()
	overheat = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), flashcd * 2)

/obj/item/assembly/flash/armimplant/try_use_flash(mob/user = null)
	if(overheat)
		var/obj/item/organ/cyberimp/arm/flash/real_arm = arm.resolve()
		if(real_arm?.owner)
			to_chat(real_arm.owner, span_warning("Your photon projector is running too hot to be used again so quickly!"))
		return FALSE
	overheat = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), flashcd)
	playsound(src, flash_sound, 100, TRUE)
	update_icon(ALL, TRUE)
	return TRUE


/obj/item/assembly/flash/armimplant/proc/cooldown()
	overheat = FALSE

/obj/item/assembly/flash/hypnotic
	desc = "A modified flash device, programmed to emit a sequence of subliminal flashes that can send a vulnerable target into a hypnotic trance."
	flashing_overlay = "flash-hypno"
	light_color = LIGHT_COLOR_PINK
	cooldown = 20

/obj/item/assembly/flash/hypnotic/burn_out()
	return

/obj/item/assembly/flash/hypnotic/flash_carbon(mob/living/carbon/M, mob/user, confusion_duration = 15, targeted = TRUE, generic_message = FALSE)
	if(!istype(M))
		return
	if(user)
		log_combat(user, M, "[targeted? "hypno-flashed(targeted)" : "hypno-flashed(AOE)"]", src)
	else //caused by emp/remote signal
		M.log_message("was [targeted? "hypno-flashed(targeted)" : "hypno-flashed(AOE)"]",LOG_ATTACK)
	if(generic_message && M != user)
		to_chat(M, span_notice("[src] emits a soothing light..."))
	if(targeted)
		if(M.flash_act(1, 1))
			var/hypnosis = FALSE
			if(M.hypnosis_vulnerable())
				hypnosis = TRUE
			if(user)
				user.visible_message(span_danger("[user] blinds [M] with the flash!"), span_danger("You hypno-flash [M]!"))

			if(!hypnosis)
				to_chat(M, span_hypnophrase("The light makes you feel oddly relaxed..."))
				M.adjust_timed_status_effect(10 SECONDS, /datum/status_effect/confusion, max_duration = 20 SECONDS)
				M.adjust_timed_status_effect(20 SECONDS, /datum/status_effect/dizziness, max_duration = 40 SECONDS)
				M.adjust_drowsyness(min(M.drowsyness+10, 20))
				M.apply_status_effect(/datum/status_effect/pacify, 100)
			else
				M.apply_status_effect(/datum/status_effect/trance, 200, TRUE)

		else if(user)
			user.visible_message(span_warning("[user] fails to blind [M] with the flash!"), span_warning("You fail to hypno-flash [M]!"))
		else
			to_chat(M, span_danger("[src] fails to blind you!"))

	else if(M.flash_act())
		to_chat(M, span_notice("Such a pretty light..."))
		M.adjust_timed_status_effect(4 SECONDS, /datum/status_effect/confusion, max_duration = 20 SECONDS)
		M.adjust_timed_status_effect(8 SECONDS, /datum/status_effect/dizziness, max_duration = 40 SECONDS)
		M.adjust_drowsyness(min(M.drowsyness+4, 20))
		M.apply_status_effect(/datum/status_effect/pacify, 40)

#undef DEVIATION_NONE
#undef DEVIATION_PARTIAL
#undef DEVIATION_FULL
