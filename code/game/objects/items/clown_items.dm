/* Clown Items
 * Contains:
 * Soap
 * Bike Horns
 * Air Horns
 * Canned Laughter
 */

/*
 * Soap
 */

/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	throwforce = 0
	throw_range = 7
	grind_results = list(/datum/reagent/lye = 10)
	var/cleanspeed = 3.5 SECONDS //slower than mop
	force_string = "robust... against germs"
	var/uses = 100

/obj/item/soap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 80)

/obj/item/soap/examine(mob/user)
	. = ..()
	var/max_uses = initial(uses)
	var/msg = "It looks like it just came out of the package."
	if(uses != max_uses)
		var/percentage_left = uses / max_uses
		switch(percentage_left)
			if(0 to 0.15)
				msg = "There's just a tiny bit left of what it used to be, you're not sure it'll last much longer."
			if(0.15 to 0.30)
				msg = "It's dissolved quite a bit, but there's still some life to it."
			if(0.30 to 0.50)
				msg = "It's past its prime, but it's definitely still good."
			if(0.50 to 0.75)
				msg = "It's started to get a little smaller than it used to be, but it'll definitely still last for a while."
			else
				msg = "It's seen some light use, but it's still pretty fresh."
	. += span_notice("[msg]")

/obj/item/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	grind_results = list(/datum/reagent/liquidgibs = 9, /datum/reagent/lye = 9)
	icon_state = "soapgibs"
	cleanspeed = 3 SECONDS // faster than base soap to reward chemists for going to the effort

/obj/item/soap/nanotrasen
	desc = "A heavy duty bar of Nanotrasen brand soap. Smells of plasma."
	grind_results = list(/datum/reagent/toxin/plasma = 10, /datum/reagent/lye = 10)
	icon_state = "soapnt"
	cleanspeed = 2.8 SECONDS //janitor gets this
	uses = 300

/obj/item/soap/nanotrasen/cyborg

/obj/item/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of high-class luxury."
	grind_results = list(/datum/reagent/consumable/aloejuice = 10, /datum/reagent/lye = 10)
	icon_state = "soapdeluxe"
	cleanspeed = 2 SECONDS //captain gets one of these

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	grind_results = list(/datum/reagent/toxin/acid = 10, /datum/reagent/lye = 10)
	icon_state = "soapsyndie"
	cleanspeed = 0.5 SECONDS //faster than mops so it's useful for traitors who want to clean crime scenes

/obj/item/soap/omega
	name = "\improper Omega soap"
	desc = "The most advanced soap known to mankind. The beginning of the end for germs."
	grind_results = list(/datum/reagent/consumable/potato_juice = 9, /datum/reagent/monkey_powder = 9, /datum/reagent/drug/krokodil = 9, /datum/reagent/toxin/acid/nitracid = 9, /datum/reagent/consumable/ethanol/hooch = 9, /datum/reagent/drug/pumpup = 9, /datum/reagent/consumable/space_cola = 9)
	icon_state = "soapomega"
	cleanspeed = 0.3 SECONDS //Only the truest of mind soul and body get one of these
	uses = 800 //In the Greek numeric system, Omega has a value of 800

/obj/item/soap/omega/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is using [src] to scrub themselves from the timeline! It looks like [user.p_theyre()] trying to commit suicide!"))
	new /obj/structure/chrono_field(user.loc, user)
	return MANUAL_SUICIDE

/obj/item/paper/fluff/stations/soap
	name = "ancient janitorial poem"
	desc = "An old paper that has passed many hands."
	info = "The legend of the omega soap</B><BR><BR> Essence of <B>potato</B>. Juice, not grind.<BR><BR> A <B>lizard's</B> tail, turned into <B>wine</B>.<BR><BR> <B>powder of monkey</B>, to help the workload.<BR><BR> Some <B>Krokodil</B>, because meth would explode.<BR><BR> <B>Nitric acid</B> and <B>Baldium</B>, for organic dissolving.<BR><BR> A cup filled with <B>Hooch</B>, for sinful absolving<BR><BR> Some <B>Bluespace Dust</B>, for removal of stains.<BR><BR> A syringe full of <B>Pump-up</B>, it's security's bane.<BR><BR> Add a can of <B>Space Cola</B>, because we've been paid.<BR><BR> <B>Heat</B> as hot as you can, let the soap be your blade.<BR><BR> <B>Ten units of each reagent create a soap that could topple all others.</B>"


/obj/item/soap/suicide_act(mob/user)
	user.say(";FFFFFFFFFFFFFFFFUUUUUUUDGE!!", forced="soap suicide")
	user.visible_message(span_suicide("[user] lifts [src] to [user.p_their()] mouth and gnaws on it furiously, producing a thick froth! [user.p_they(TRUE)]'ll never get that BB gun now!"))
	new /obj/effect/particle_effect/fluid/foam(loc)
	return (TOXLOSS)

/**
 * Decrease the number of uses the bar of soap has.
 *
 * The higher the cleaning skill, the less likely the soap will lose a use.
 * Arguments
 * * user - The mob that is using the soap to clean.
 */
/obj/item/soap/proc/decreaseUses(mob/user)
	var/skillcheck = 1
	if(user?.mind)
		skillcheck = user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)
	if(prob(skillcheck*100)) //higher level = more uses assuming RNG is nice
		uses--
	if(uses <= 0)
		noUses(user)

/obj/item/soap/proc/noUses(mob/user)
	to_chat(user, span_warning("[src] crumbles into tiny bits!"))
	qdel(src)

/obj/item/soap/nanotrasen/cyborg/noUses(mob/user)
	to_chat(user, span_warning("The soap has ran out of chemicals"))


/obj/item/soap/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.combat_mode)
		return NONE

	if(!check_allowed_items(interacting_with))
		return NONE


	var/clean_speedies = 1 * cleanspeed
	if(user.mind)
		clean_speedies = cleanspeed * min(user.mind.get_skill_modifier(/datum/skill/cleaning, SKILL_SPEED_MODIFIER)+0.1,1) //less scaling for soapies

	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && ((interacting_with in user.client.screen) && !user.is_holding(interacting_with)))
		to_chat(user, span_warning("You need to take that [interacting_with.name] off before cleaning it!"))

	else if(istype(interacting_with, /obj/effect/decal/cleanable))
		user.visible_message(span_notice("[user] begins to scrub \the [interacting_with.name] out with [src]."), span_warning("You begin to scrub \the [interacting_with.name] out with [src]..."))
		if(do_after(user, interacting_with, clean_speedies))
			to_chat(user, span_notice("You scrub \the [interacting_with.name] out."))
			var/obj/effect/decal/cleanable/cleanies = interacting_with
			user.mind?.adjust_experience(/datum/skill/cleaning, max(round(cleanies.beauty/CLEAN_SKILL_BEAUTY_ADJUSTMENT),0)) //again, intentional that this does NOT round but mops do.
			qdel(interacting_with)
			decreaseUses(user)
			return ITEM_INTERACT_SUCCESS

	else if(ishuman(interacting_with) && user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		var/mob/living/carbon/human/human_target = interacting_with
		user.visible_message(span_warning("\the [user] washes \the [interacting_with]'s mouth out with [src.name]!"), span_notice("You wash \the [interacting_with]'s mouth out with [src.name]!")) //washes mouth out with soap sounds better than 'the soap' here if(user.zone_selected == "mouth")
		if(human_target.lip_style)
			user.mind?.adjust_experience(/datum/skill/cleaning, CLEAN_SKILL_GENERIC_WASH_XP)
			human_target.update_lips(null)
		decreaseUses(user)
		return ITEM_INTERACT_SUCCESS

	else if(istype(interacting_with, /obj/structure/window))
		user.visible_message(span_notice("[user] begins to clean \the [interacting_with.name] with [src]..."), span_notice("You begin to clean \the [interacting_with.name] with [src]..."))
		if(do_after(user, interacting_with, clean_speedies))
			to_chat(user, span_notice("You clean \the [interacting_with.name]."))
			interacting_with.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			interacting_with.set_opacity(initial(interacting_with.opacity))
			var/obj/structure/window/our_window = interacting_with
			if(our_window.bloodied)
				for(var/obj/effect/decal/cleanable/blood/iter_blood in our_window)
					our_window.remove_viscontents(iter_blood)
					qdel(iter_blood)
					our_window.bloodied = FALSE
			user.mind?.adjust_experience(/datum/skill/cleaning, CLEAN_SKILL_GENERIC_WASH_XP)
			decreaseUses(user)
			return ITEM_INTERACT_SUCCESS
	else
		user.visible_message(span_notice("[user] begins to clean \the [interacting_with.name] with [src]..."), span_notice("You begin to clean \the [interacting_with.name] with [src]..."))
		if(do_after(user, interacting_with, clean_speedies))
			to_chat(user, span_notice("You clean \the [interacting_with.name]."))
			if(user && isturf(interacting_with))
				for(var/obj/effect/decal/cleanable/cleanable_decal in interacting_with)
					user.mind?.adjust_experience(/datum/skill/cleaning, round(cleanable_decal.beauty / CLEAN_SKILL_BEAUTY_ADJUSTMENT))
			interacting_with.wash(CLEAN_SCRUB)
			interacting_with.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			user.mind?.adjust_experience(/datum/skill/cleaning, CLEAN_SKILL_GENERIC_WASH_XP)
			decreaseUses(user)
			return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/item/soap/nanotrasen/cyborg/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(uses <= 0)
		to_chat(user, span_warning("No good, you need to recharge!"))
		return NONE
	return ..()


/*
 * Bike Horns
 */

/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle. Rumour has it that they're made from recycled clowns."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bike_horn"
	inhand_icon_state = "bike_horn"
	worn_icon_state = "horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	throwforce = 0
	hitsound = null //To prevent tap.ogg playing, as the item lacks of force
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	throw_range = 7
	attack_verb_continuous = list("HONKS")
	attack_verb_simple = list("HONK")
	///sound file given to the squeaky component we make in Initialize() so sub-types can specify their own sound
	var/sound_file = 'sound/items/bikehorn.ogg'

/obj/item/bikehorn/Initialize(mapload)
	. = ..()
	var/list/sound_list = list()
	sound_list[sound_file] = 1
	AddComponent(/datum/component/squeak, sound_list, 50, falloff_exponent = 20)

/obj/item/bikehorn/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] solemnly points [src] at [user.p_their()] temple! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return (BRUTELOSS)

//air horn
/obj/item/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	worn_icon_state = "horn_air"
	sound_file = 'sound/items/airhorn2.ogg'

//golden bikehorn
/obj/item/bikehorn/golden
	name = "golden bike horn"
	desc = "Golden? Clearly, it's made with bananium! Honk!"
	icon_state = "gold_horn"
	inhand_icon_state = "gold_horn"
	worn_icon_state = "horn_gold"
	COOLDOWN_DECLARE(golden_horn_cooldown)

/obj/item/bikehorn/golden/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isliving(interacting_with))
		flip_mobs()
		user.do_attack_animation(interacting_with, used_item = src, do_hurt = FALSE)
		return ITEM_INTERACT_SUCCESS

/obj/item/bikehorn/golden/attack_self(mob/user)
	flip_mobs()
	. = ..()

/obj/item/bikehorn/golden/proc/flip_mobs(mob/living/carbon/M, mob/user)
	if(!COOLDOWN_FINISHED(src, golden_horn_cooldown))
		return
	var/turf/T = get_turf(src)
	for(M in ohearers(7, T))
		if(M.can_hear())
			M.emote("flip")
	COOLDOWN_START(src, golden_horn_cooldown, 1 SECONDS)

//canned laughter
/obj/item/reagent_containers/cup/soda_cans/canned_laughter
	name = "Canned Laughter"
	desc = "Just looking at this makes you want to giggle."
	icon_state = "laughter"
	list_reagents = list(/datum/reagent/consumable/laughter = 50)
