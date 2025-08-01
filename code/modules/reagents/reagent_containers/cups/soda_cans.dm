//These are in their own group to be used as IED's in /obj/item/grenade/ghettobomb.dm
/// How much fizziness is added to the can of soda by throwing it, in percentage points
#define SODA_FIZZINESS_THROWN 15
/// How much fizziness is added to the can of soda by shaking it, in percentage points
#define SODA_FIZZINESS_SHAKE 5

/obj/item/reagent_containers/cup/soda_cans
	name = "soda can"
	icon = 'icons/obj/drinks.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = NONE
	spillable = FALSE
	isGlass = FALSE
	custom_price = PAYCHECK_ASSISTANT * 0.9
	obj_flags = CAN_BE_HIT
	throwforce = 12 // set to 0 upon being opened. Have you ever been domed by a soda can? Those things fucking hurt

	possible_transfer_amounts = list(5, 10, 15, 25, 30)
	volume = 30

	/// If the can hasn't been opened yet, this is the measure of how fizzed up it is from being shaken or thrown around. When opened, this is rolled as a percentage chance to burst
	var/fizziness = 0

/obj/item/reagent_containers/cup/soda_cans/random/Initialize(mapload)
	..()
	var/T = pick(subtypesof(/obj/item/reagent_containers/cup/soda_cans) - /obj/item/reagent_containers/cup/soda_cans/random)
	new T(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/reagent_containers/cup/soda_cans/suicide_act(mob/living/carbon/human/H)
	if(!reagents.total_volume)
		H.visible_message(span_warning("[H] is trying to take a big sip from [src]... The can is empty!"))
		return SHAME
	if(!is_drainable())
		open_soda()
		sleep(10)
	H.visible_message(span_suicide("[H] takes a big sip from [src]! It looks like [H.p_theyre()] trying to commit suicide!"))
	playsound(H,'sound/items/drink.ogg', 80, TRUE)
	reagents.trans_to(H, src.reagents.total_volume, transfered_by = H) //a big sip
	sleep(5)
	H.say(pick("Now, Outbomb Cuban Pete, THAT was a game.", "All these new fangled arcade games are too slow. I prefer the classics.", "They don't make 'em like Orion Trail anymore.", "You know what they say. Worst day of spess carp fishing is better than the best day at work.", "They don't make 'em like good old-fashioned singularity engines anymore."))
	if(H.age >= 30)
		H.Stun(50)
		sleep(50)
		playsound(H,'sound/items/drink.ogg', 80, TRUE)
		H.say(pick("Another day, another dollar.", "I wonder if I should hold?", "Diversifying is for young'ns.", "Yeap, times were good back then."))
		return MANUAL_SUICIDE_NONLETHAL
	sleep(20) //dramatic pause
	return TOXLOSS

/obj/item/reagent_containers/cup/soda_cans/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(ishuman(interacting_with) && !reagents.total_volume && user.combat_mode && user.zone_selected == BODY_ZONE_HEAD)
		if(interacting_with == user)
			user.visible_message(
				span_warning("[user] crushes the can of [src] on [user.p_their()] forehead."),
				blind_message = span_hear("You hear a small metal can being crushed.")
			)
		else
			user.visible_message(
				span_warning("<b>[user]</b> crushes the can of [src] on <b>[interacting_with]</b>'s forehead."),
				blind_message = span_hear("You hear a small metal can being crushed."),
			)
		playsound(interacting_with, 'sound/weapons/pierce.ogg', rand(10,50), TRUE)
		var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(interacting_with.drop_location())
		crushed_can.icon_state = icon_state
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	return ..()

/obj/item/reagent_containers/cup/soda_cans/bullet_act(obj/projectile/P)
	. = ..()
	if(!(P.nodamage) && P.damage_type == BRUTE && !QDELETED(src))
		var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(src.loc)
		crushed_can.icon_state = icon_state
		var/atom/throw_target = get_edge_target_turf(crushed_can, pick(GLOB.alldirs))
		crushed_can.throw_at(throw_target, rand(1,2), 7)
		qdel(src)
		return

/obj/item/reagent_containers/cup/soda_cans/proc/open_soda(mob/user)
	if(prob(fizziness))
		user.visible_message(span_danger("[user] opens [src], and is suddenly sprayed by the fizzing contents!"), span_danger("You pull back the tab of [src], and are suddenly sprayed with a torrent of liquid! Ahhh!!"))
		burst_soda(user)
		return

	to_chat(user, "You pull back the tab of [src] with a satisfying pop.") //Ahhhhhhhh
	reagents.flags |= OPENCONTAINER
	playsound(src, SFX_CAN_OPEN, 50, TRUE)
	spillable = TRUE
	throwforce = 0

/**
 * Burst the soda open on someone. Fun! Opens and empties the soda can, but does not crush it.
 *
 * Arguments:
 * * target - Who's getting covered in soda
 * * hide_message - Stops the generic fizzing message, so you can do your own
 */
/obj/item/reagent_containers/cup/soda_cans/proc/burst_soda(atom/target, hide_message = FALSE)
	if(!target)
		return

	playsound(src, 'sound/effects/can_pop.ogg', 80, TRUE)
	if(!hide_message)
		visible_message(span_danger("[src] spills over, fizzing its contents all over [target]!"))
	spillable = TRUE
	reagents.flags |= OPENCONTAINER
	reagents.expose(target, TOUCH)
	reagents.clear_reagents()
	throwforce = 0

/obj/item/reagent_containers/cup/soda_cans/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || spillable || !reagents.total_volume) // if it was caught, already opened, or has nothing in it
		return

	fizziness += SODA_FIZZINESS_THROWN
	if(!prob(fizziness))
		return

	burst_soda(hit_atom, hide_message = TRUE)
	visible_message(span_danger("[src]'s impact with [hit_atom] causes it to rupture, spilling everywhere!"))
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(src.loc)
	crushed_can.icon_state = icon_state
	moveToNullspace()
	QDEL_IN(src, 1 SECONDS) // give it a second so it can still be logged for the throw impact

/obj/item/reagent_containers/cup/soda_cans/attack_self(mob/user)
	if(!is_drainable())
		open_soda(user)
		return
	return ..()

/obj/item/reagent_containers/cup/soda_cans/attack_self_secondary(mob/user)
	if(!is_drainable())
		playsound(src, 'sound/effects/can_shake.ogg', 50, TRUE)
		user.visible_message(span_danger("[user] shakes [src]!"), span_danger("You shake up [src]!"), vision_distance=2)
		fizziness += SODA_FIZZINESS_SHAKE
		return
	return ..()

/obj/item/reagent_containers/cup/soda_cans/examine_more(mob/user)
	. = ..()
	if(!in_range(user, src))
		return
	if(fizziness > 30 && prob(fizziness * 2))
		. += span_notice("<i>You examine [src] closer, and note the following...</i>")
		. += "\t[span_warning("You get a menacing aura of fizziness from it...")]"

#undef SODA_FIZZINESS_THROWN
#undef SODA_FIZZINESS_SHAKE

/obj/item/reagent_containers/cup/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 30)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/soda_cans/tonic
	name = "T-Borg's tonic water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	list_reagents = list(/datum/reagent/consumable/tonic = 50)
	drink_type = ALCOHOL

/obj/item/reagent_containers/cup/soda_cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)

/obj/item/reagent_containers/cup/soda_cans/lemon_lime
	name = "orange soda"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list(/datum/reagent/consumable/lemon_lime = 30)
	drink_type = FRUIT

/obj/item/reagent_containers/cup/soda_cans/lemon_lime/Initialize(mapload)
	. = ..()
	name = "lemon-lime soda"

/obj/item/reagent_containers/cup/soda_cans/sol_dry
	name = "Sol Dry"
	desc = "Maybe this will help your tummy feel better. Maybe not."
	icon_state = "sol_dry"
	list_reagents = list(/datum/reagent/consumable/sol_dry = 30)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/soda_cans/space_up
	name = "Space-Up!"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list(/datum/reagent/consumable/space_up = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list(/datum/reagent/consumable/space_cola = 15, /datum/reagent/consumable/orangejuice = 15)
	drink_type = SUGAR | FRUIT | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list(/datum/reagent/consumable/spacemountainwind = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list(/datum/reagent/consumable/dr_gibb = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/shamblers
	name = "Shambler's juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers"
	list_reagents = list(/datum/reagent/consumable/shamblers = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/grey_bull
	name = "Grey Bull"
	desc = "Grey Bull, it gives you gloves!"
	icon_state = "energy_drink"
	list_reagents = list(/datum/reagent/consumable/grey_bull = 20)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/monkey_energy
	name = "Monkey Energy"
	desc = "Unleash the ape!"
	icon_state = "monkey_energy"
	inhand_icon_state = "monkey_energy"
	list_reagents = list(/datum/reagent/consumable/monkey_energy = 50)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/air
	name = "canned air"
	desc = "There is no air shortage. Do not drink."
	icon_state = "air"
	list_reagents = list(/datum/reagent/nitrogen = 24, /datum/reagent/oxygen = 6)
