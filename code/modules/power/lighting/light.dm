// the standard tube light fixture
DEFINE_INTERACTABLE(/obj/machinery/light)
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	power_channel = AREA_USAGE_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	///What overlay the light should use
	var/overlay_icon = 'icons/obj/lighting_overlay.dmi'
	///base description and icon_state
	var/base_state = "tube"

	///Is the light on?
	var/on = FALSE
	///compared to the var/on for static calculations
	var/on_gs = FALSE
	///Amount of power used
	var/static_power_used = 0
	///The outer radius of the light's... light.
	var/bulb_outer_range = 9
	///The inner radius of the bulb's light, where it is at maximum brightness
	var/bulb_inner_range = 1.8
	///Basically the alpha of the emitted light source
	var/bulb_power = 0.6
	///The falloff of the emitted light. Adjust until it looks good.
	var/bulb_falloff = 1.85
	///Default colour of the light.
	var/bulb_colour = LIGHTBULB_COLOR_WARM
	///LIGHT_OK, _EMPTY, _BURNED or _BROKEN

	var/status = LIGHT_OK
	///Should we flicker?
	var/flickering = FALSE
	///The type of light item
	var/light_type = /obj/item/light/tube
	///String of the light type, used in descriptions and in examine
	var/fitting = "tube"
	///Count of number of times switched on/off, this is used to calculate the probability the light burns out
	var/switchcount = 0
	///True if rigged to explode
	var/rigged = FALSE
	/// Is the bulb removable
	var/removable_bulb = TRUE
	/// Is it pixel shifted onto walls?
	var/align_with_wall = TRUE
	///Cell reference
	var/obj/item/stock_parts/cell/cell
	///If true, this fixture generates a very weak cell at roundstart
	var/start_with_cell = TRUE

	///If true, the light is in emergency mode
	var/emergency_mode = FALSE
	///If true, this light cannot ever have an emergency mode
	var/no_emergency = FALSE
	///Multiplier for this light's base brightness in emergency power mode
	var/bulb_emergency_brightness_mul = 0.8
	///Determines the colour of the light while it's in emergency mode
	var/bulb_emergency_colour = "#FF3232"
	///The multiplier for determining the light's power in emergency mode
	var/bulb_emergency_pow_mul = 0.6
	///The minimum value for the light's power in emergency mode
	var/bulb_emergency_pow_min = 0.2

	///The area this thing is in.
	var/area/my_area = null

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		break_light_tube(TRUE)
	return ..()

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()
	SET_TRACKING(__TYPE__)

	if(start_with_cell && !no_emergency)
		cell = new/obj/item/stock_parts/cell/emergency_light(src)

	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))
	become_atmos_sensitive()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/LateInitialize()
	. = ..()
	my_area = get_area(src)
	if(my_area)
		LAZYADD(my_area.lights, src)

	#ifdef LIGHTS_RANDOMLY_BROKEN
	switch(fitting)
		if("tube")
			if(prob(0.5))
				break_light_tube(TRUE)
		if("bulb")
			if(prob(1))
				break_light_tube(TRUE)
	#endif
	update(FALSE, TRUE, FALSE)

/obj/machinery/light/Destroy()
	UNSET_TRACKING(__TYPE__)
	if(my_area)
		on = FALSE
		LAZYREMOVE(my_area.lights, src)
	my_area = null
	QDEL_NULL(cell)
	lose_atmos_sensitivity()
	return ..()

/obj/machinery/light/update_icon_state()
	switch(status) // set icon_states
		if(LIGHT_OK)
			//var/area/local_area = get_area(src) //PARIAH EDIT REMOVAL
			if(emergency_mode || firealarm) //PARIAH EDIT CHANGE
				icon_state = "[base_state]_emergency"
			else
				icon_state = "[base_state]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	return ..()

/obj/machinery/light/update_overlays()
	. = ..()
	if(!on || status != LIGHT_OK)
		return

	if(!overlay_icon)
		return

	if(emergency_mode || firealarm) //PARIAH EDIT END
		. += mutable_appearance(overlay_icon, "[base_state]_emergency")
		return
	. += mutable_appearance(overlay_icon, base_state)

/obj/machinery/light/setDir(ndir)
	. = ..()
	if(!align_with_wall)
		return

	switch(dir)
		if(NORTH)
			pixel_y = 21
			pixel_x = 0
		if(SOUTH)
			pixel_y = 0
			pixel_x = 0
		if(EAST)
			pixel_x = 10
			pixel_y = 0
		if(WEST)
			pixel_x = -10
			pixel_y = 0

//PARIAH EDIT ADDITION
#define LIGHT_ON_DELAY_UPPER 3 SECONDS
#define LIGHT_ON_DELAY_LOWER 1 SECONDS
//PARIAH EDIT END

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE, instant = FALSE, play_sound = TRUE) //PARIAH EDIT CHANGE
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	emergency_mode = FALSE
	if(on)
		if(instant)
			turn_on(trigger, play_sound)

		else if(maploaded)
			turn_on(trigger)
			maploaded = FALSE

		else if(!turning_on)
			turning_on = TRUE
			addtimer(CALLBACK(src, PROC_REF(turn_on), trigger, play_sound), rand(LIGHT_ON_DELAY_LOWER, LIGHT_ON_DELAY_UPPER))

	else if(has_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		if(use_power != NO_POWER_USE)
			use_power = IDLE_POWER_USE
		emergency_mode = TRUE
		START_PROCESSING(SSmachines, src)

	else
		if(use_power != NO_POWER_USE)
			use_power = IDLE_POWER_USE
		set_light(0)

	update_appearance()

	if(on != on_gs)
		on_gs = on
		if(on)
			static_power_used = bulb_outer_range * 20 //20W per unit luminosity
			addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)

	broken_sparks(start_only=TRUE)

//PARIAH EDIT
#undef LIGHT_ON_DELAY_UPPER
#undef LIGHT_ON_DELAY_LOWER
//PARIAH EDIT END

/obj/machinery/light/update_atom_colour()
	..()
	update()

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	if(!QDELETED(src) && status == LIGHT_BROKEN && has_power() && MC_RUNNING())
		if(!start_only)
			do_sparks(3, TRUE, src)
		var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
		addtimer(CALLBACK(src, PROC_REF(broken_sparks)), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/process()
	if (!cell)
		return PROCESS_KILL
	if(has_power())
		if (cell.charge == cell.maxcharge)
			return PROCESS_KILL
		cell.charge = min(cell.maxcharge, cell.charge + LIGHT_EMERGENCY_POWER_USE) //Recharge emergency power automatically while not using it
	if(emergency_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE))
		update(FALSE) //Disables emergency mode and sets the color to normal

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(0)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/set_on(turn_on)
	on = (turn_on && status == LIGHT_OK)
	update()

/obj/machinery/light/get_cell()
	return cell

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			if(!on)
				. += span_notice("It is turned off.")
		if(LIGHT_EMPTY)
			. += span_notice("The [fitting] has been removed.")
		if(LIGHT_BURNED)
			. += span_notice("The [fitting] is burnt out.")
		if(LIGHT_BROKEN)
			. += span_alert("The [fitting] has been smashed.")

	if(cell)
		. += span_notice("Its backup power charge meter reads: [round((cell.charge / cell.maxcharge) * 100, 0.1)]%.")

	if(constant_flickering)
		. += span_alert("The lighting ballast appears to be damaged, this could be fixed with a multitool.")

	if(is_station_level(z))
		var/datum/roll_result/result = user.get_examine_result("light", 12)
		if(result?.outcome >= SUCCESS)
			result.do_skill_sound(user)
			. += result.create_tooltip("A ninety-three degree fire rages within a gaseous prison.", body_only = TRUE)

/obj/machinery/light/disco_flavor(mob/living/carbon/human/user, nearby, is_station_level)
	. = ..()
	if(!is_station_level)
		return

	var/datum/roll_result/result = user.get_examine_result("light_flavor", only_once = TRUE)
	if(result?.outcome >= SUCCESS)
		result.do_skill_sound(user)
		to_chat(
			user,
			result.create_tooltip("These lightbulbs are ancient. Their filaments hum with the weary resolve of a thousand nights endured. Each one a tiny sun, bolted to the wall to light a colony that has long forgotten them. They illuminate the cracked walls and faces bathed in time, their faint flickering revealing the uncertainty in the air."),
		)

// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/tool, mob/living/user, params)
	//Light replacer code
	if(istype(tool, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/replacer = tool
		replacer.ReplaceLight(src, user)
		return TRUE

	//PARIAH EDIT ADDITION
	if(istype(tool, /obj/item/multitool) && constant_flickering)
		to_chat(user, span_notice("You start repairing the ballast of [src] with [tool]."))
		if(do_after(user, src, 2 SECONDS, DO_PUBLIC, display = tool))
			stop_flickering()
			to_chat(user, span_notice("You repair the ballast of [src]!"))
		return TRUE
	//PARIAH EDIT END

	// attempt to insert light
	if(istype(tool, /obj/item/light))
		if(!removable_bulb)
			to_chat(user, span_warning("[src]'s bulb does not appear to come out."))
		if(status == LIGHT_OK)
			to_chat(user, span_warning("There is a [fitting] already inserted."))
			return TRUE

		tool.leave_evidence(user, src)

		var/obj/item/light/light_object = tool
		if(!istype(light_object, light_type))
			to_chat(user, span_warning("This type of light requires a [fitting]!"))
			return TRUE
		if(!user.temporarilyRemoveItemFromInventory(light_object))
			return TRUE

		tool.leave_evidence(user, src)
		if(status != LIGHT_EMPTY)
			drop_light_tube(user)
			to_chat(user, span_notice("You replace [light_object]."))
		else
			to_chat(user, span_notice("You insert [light_object]."))
		status = light_object.status
		switchcount = light_object.switchcount
		rigged = light_object.rigged
		bulb_inner_range = light_object.bulb_inner_range
		bulb_outer_range = light_object.bulb_outer_range
		on = has_power()
		update()

		qdel(light_object)

		if(on && rigged)
			explode()
		return TRUE

	if(istype(tool, /obj/item/stock_parts/cell))
		return FALSE

	if(status != LIGHT_EMPTY)
		return ..()
	to_chat(user, span_userdanger("You stick \the [tool] into the light socket!"))
	if(has_power() && (tool.flags_1 & CONDUCT_1))
		do_sparks(3, TRUE, src)
		if (prob(75))
			electrocute_mob(user, get_area(src), src, (rand(7,10) * 0.1), TRUE)

	return TRUE


/obj/machinery/light/screwdriver_act(mob/living/user, obj/item/tool)
	if(status != LIGHT_EMPTY)
		return ..()

	tool.play_tool_sound(src, 75)
	user.visible_message(span_notice("[user.name] opens [src]'s casing."), \
		span_notice("You open [src]'s casing."), span_hear("You hear a noise."))
	deconstruct()

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		qdel(src)
		return

	var/obj/structure/light_construct/new_light = null
	var/current_stage = 2
	if(!disassembled)
		current_stage = 1

	switch(fitting)
		if("tube")
			new_light = new /obj/structure/light_construct(loc)
			new_light.icon_state = "tube-construct-stage[current_stage]"

		if("bulb")
			new_light = new /obj/structure/light_construct/small(loc)
			new_light.icon_state = "bulb-construct-stage[current_stage]"

	new_light.setDir(dir)
	new_light.stage = current_stage

	if(!disassembled)
		new_light.take_damage(new_light.max_integrity * 0.5, sound_effect=FALSE)
		if(status != LIGHT_BROKEN)
			break_light_tube()

		if(status != LIGHT_EMPTY && removable_bulb)
			drop_light_tube()

		new /obj/item/stack/cable_coil(loc, 1, "red")

	transfer_fingerprints_to(new_light)

	if(!QDELETED(cell))
		new_light.cell = cell
		cell.forceMove(new_light)
		cell = null
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/attacking_object, mob/living/user)
	..()
	if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)
		return
	if(!on || !(attacking_object.flags_1 & CONDUCT_1))
		return
	if(prob(12))
		electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/local_area = get_area(src)
	return !local_area.lightswitch && local_area.power_light || flickering || constant_flickering //PARIAH EDIT CHANGE

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/local_area = get_area(src)
	//PARIAH EDIT ADDITION
	if(isnull(local_area))
		return FALSE
	//PARIAH EDIT END
	return local_area.lightswitch && local_area.power_light

// returns whether this light has emergency power
// can also return if it has access to a certain amount of that power
/obj/machinery/light/proc/has_emergency_power(power_usage_amount)
	if(no_emergency || !cell)
		return FALSE
	if(power_usage_amount ? cell.charge >= power_usage_amount : cell.charge)
		return status == LIGHT_OK

// attempts to use power from the installed emergency cell, returns true if it does and false if it doesn't
/obj/machinery/light/proc/use_emergency_power(power_usage_amount = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(power_usage_amount))
		return FALSE
	if(cell.charge > 300) //it's meant to handle 120 W, ya doofus
		visible_message(span_warning("[src] short-circuits from too powerful of a power cell!"))
		burn_out()
		return FALSE
	cell.use(power_usage_amount)
	set_light(
			l_outer_range = bulb_outer_range * bulb_emergency_brightness_mul,
			l_inner_range = bulb_inner_range * bulb_emergency_brightness_mul,
			l_power = max(bulb_emergency_pow_min, bulb_emergency_pow_mul * (cell.charge / cell.maxcharge)),
			l_color = bulb_emergency_colour
		)
	return TRUE


/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	set waitfor = FALSE
	if(flickering)
		return

	flickering = TRUE
	if(on && status == LIGHT_OK)
		for(var/i in 1 to amount)
			if(status != LIGHT_OK)
				break
			on = !on
			update(FALSE, TRUE)
			sleep(rand(5, 15))

		on = (status == LIGHT_OK)
		update(FALSE, TRUE)

	flickering = FALSE

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	no_emergency = !no_emergency
	to_chat(user, span_notice("Emergency lights for this fixture have been [no_emergency ? "disabled" : "enabled"]."))
	update(FALSE)
	return

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)

	if(status == LIGHT_EMPTY)
		to_chat(user, span_warning("There is no [fitting] in this light!"))
		return TRUE

	if(!removable_bulb)
		to_chat(user, span_warning("[src]'s bulb does not appear to come out."))
		return TRUE

	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits
	if(!on)
		to_chat(user, span_notice("You remove the light [fitting]."))
		// create a light tube/bulb item and put it in the user's hand
		drop_light_tube(user)
		return TRUE

	var/protection_amount = 0
	var/mob/living/carbon/human/electrician = user

	if(istype(electrician))
		var/obj/item/organ/stomach/maybe_stomach = electrician.getorganslot(ORGAN_SLOT_STOMACH)
		if(istype(maybe_stomach, /obj/item/organ/stomach/ethereal))
			var/obj/item/organ/stomach/ethereal/stomach = maybe_stomach
			if(stomach.drain_time > world.time)
				return
			to_chat(electrician, span_notice("You start channeling some power through the [fitting] into your body."))
			stomach.drain_time = world.time + LIGHT_DRAIN_TIME
			while(do_after(user, src, LIGHT_DRAIN_TIME))
				stomach.drain_time = world.time + LIGHT_DRAIN_TIME
				if(istype(stomach))
					to_chat(electrician, span_notice("You receive some charge from the [fitting]."))
					stomach.adjust_charge(LIGHT_POWER_GAIN)
				else
					to_chat(electrician, span_warning("You can't receive charge from the [fitting]!"))
			return

		if(electrician.gloves)
			var/obj/item/clothing/gloves/electrician_gloves = electrician.gloves
			if(electrician_gloves.max_heat_protection_temperature)
				protection_amount = (electrician_gloves.max_heat_protection_temperature > 360)
	else
		protection_amount = 1

	if(protection_amount > 0 || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		to_chat(user, span_notice("You remove the light [fitting]."))
	else if(istype(user) && user.dna.check_mutation(/datum/mutation/human/telekinesis))
		to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	else
		var/obj/item/bodypart/affecting = electrician.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
		affecting?.receive_damage( 0, 5 )
		if(HAS_TRAIT(user, TRAIT_LIGHTBULB_REMOVER))
			to_chat(user, span_notice("You feel like you're burning, but you can push through."))
			if(!do_after(user, src, 5 SECONDS))
				return
			affecting?.receive_damage( 0, 10 ) // 10 more burn damage
			to_chat(user, span_notice("You manage to remove the light [fitting], shattering it in process."))
			break_light_tube()
		else
			to_chat(user, span_warning("You try to remove the light [fitting], but you burn your hand on it!"))
			return

	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)
	return TRUE

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/light_object = new light_type()
	light_object.status = status
	light_object.rigged = rigged
	light_object.bulb_inner_range = bulb_inner_range
	light_object.bulb_outer_range = bulb_outer_range

	// light item inherits the switchcount, then zero it
	light_object.switchcount = switchcount
	switchcount = 0

	light_object.update()
	light_object.forceMove(loc)

	if(user) //puts it in our active hand
		light_object.add_fingerprint(user)
		user.put_in_active_hand(light_object)

	status = LIGHT_EMPTY
	update()
	return light_object

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, span_warning("There is no [fitting] in this light!"))
		return

	to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/light_tube = drop_light_tube()
	return light_tube.attack_tk(user)

// break the light and make sparks if was on
/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = FALSE)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(on)
			do_sparks(3, TRUE, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	bulb_inner_range = initial(bulb_inner_range)
	bulb_outer_range = initial(bulb_outer_range)
	on = TRUE
	update()

/obj/machinery/light/zap_act(power, zap_flags)
	var/explosive = zap_flags & ZAP_MACHINE_EXPLOSIVE
	zap_flags &= ~(ZAP_MACHINE_EXPLOSIVE | ZAP_OBJ_DAMAGE)
	. = ..()
	if(explosive)
		explosion(src, flame_range = 5, adminlog = FALSE)
		qdel(src)

// called when area power state changes
/obj/machinery/light/power_change()
	SHOULD_CALL_PARENT(FALSE)
	var/area/local_area = get_area(src)
	set_on(local_area.lightswitch && local_area.power_light)

/obj/machinery/light/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

// explode the light

/obj/machinery/light/proc/explode()
	set waitfor = 0
	break_light_tube() // break it first to give a warning
	sleep(2)
	explosion(src, light_impact_range = 2, flash_range = -1)
	sleep(1)
	qdel(src)

/obj/machinery/light/proc/on_light_eater(obj/machinery/light/source, datum/light_eater)
	SIGNAL_HANDLER
	. = COMPONENT_BLOCK_LIGHT_EATER
	if(status == LIGHT_EMPTY)
		return
	var/obj/item/light/tube = drop_light_tube()
	tube?.burn()
	return

/obj/item/debuglights
	///The outer radius of the light's... light.
	var/bulb_outer_range = 7
	///The inner radius of the bulb's light, where it is at maximum brightness
	var/bulb_inner_range = 1.5
	///Basically the alpha of the emitted light source
	var/bulb_power = 1
	var/bulb_falloff = LIGHTING_DEFAULT_FALLOFF_CURVE
	///Default colour of the light.
	var/bulb_colour = "#f2f9f7"

/obj/item/debuglights/Initialize(mapload)
	. = ..()
	var/obj/machinery/light/model_light = /obj/machinery/light
	bulb_outer_range = initial(model_light.bulb_outer_range)
	bulb_inner_range = initial(model_light.bulb_inner_range)
	bulb_power = initial(model_light.bulb_power)
	bulb_falloff = initial(model_light.bulb_falloff)
	bulb_colour = initial(model_light.bulb_colour)

/obj/item/debuglights/attack_self(mob/user, modifiers)
	set waitfor = FALSE
	for(var/obj/machinery/light/L in range(40, user))
		L.set_light(bulb_outer_range, bulb_inner_range, bulb_power, bulb_falloff, bulb_colour)
		CHECK_TICK


// DEBUG VERBS
// /obj/machinery/light/verb/_change_color()
// 	set name = "Mass Change Color"
// 	set category = "Debug"
// 	set src in view(5)

// 	var/new_color = input(usr, "New Color", "Change Color", bulb_colour) as null|color
// 	if(!new_color)
// 		return

// 	var/old_color = bulb_colour

// 	for(var/obj/machinery/light/L as anything in INSTANCES_OF(/obj/machinery/light))
// 		if(L.bulb_colour == old_color && is_station_level(L.z))
// 			L.bulb_colour = new_color
// 			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)

// 		CHECK_TICK

// /obj/machinery/light/verb/_change_power()
// 	set name = "Mass Change Power"
// 	set category = "Debug"
// 	set src in view(5)

// 	var/new_power = input(usr, "New Color", "Change Color", bulb_power) as null|num
// 	if(!new_power)
// 		return

// 	var/old_power = bulb_power

// 	for(var/obj/machinery/light/L as anything in INSTANCES_OF(/obj/machinery/light))
// 		if(L.bulb_power == old_power && is_station_level(L.z))
// 			L.bulb_power = new_power
// 			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)

// 		CHECK_TICK

// /obj/machinery/light/verb/_change_orange()
// 	set name = "Mass Change ORange"
// 	set category = "Debug"
// 	set src in view(5)

// 	var/new_orange = input(usr, "New Color", "Change Color", bulb_outer_range) as null|num
// 	if(!new_orange)
// 		return

// 	var/old_orange = bulb_outer_range

// 	for(var/obj/machinery/light/L as anything in INSTANCES_OF(/obj/machinery/light))
// 		if(L.bulb_outer_range == old_orange && is_station_level(L.z))
// 			L.bulb_outer_range = new_orange
// 			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)

// 		CHECK_TICK

// /obj/machinery/light/verb/_change_irange()
// 	set name = "Mass Change IRange"
// 	set category = "Debug"
// 	set src in view(5)

// 	var/new_irange = input(usr, "New Color", "Change Color", bulb_inner_range) as null|num
// 	if(!new_irange)
// 		return

// 	var/old_irange = bulb_inner_range

// 	for(var/obj/machinery/light/L as anything in INSTANCES_OF(/obj/machinery/light))
// 		if(L.bulb_inner_range == old_irange && is_station_level(L.z))
// 			L.bulb_inner_range = new_irange
// 			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)

// 		CHECK_TICK

// /obj/machinery/light/verb/_change_falloff()
// 	set name = "Mass Change Falloff"
// 	set category = "Debug"
// 	set src in view(5)

// 	var/new_falloff = input(usr, "New Color", "Change Color", bulb_falloff) as null|num
// 	if(!new_falloff)
// 		return

// 	var/old_falloff = bulb_falloff

// 	for(var/obj/machinery/light/L as anything in INSTANCES_OF(/obj/machinery/light))
// 		if(L.bulb_falloff == old_falloff && is_station_level(L.z))
// 			L.bulb_falloff = new_falloff
// 			L.set_light(L.bulb_outer_range, L.bulb_inner_range, L.bulb_power, L.bulb_falloff, L.bulb_colour)

// 		CHECK_TICK
