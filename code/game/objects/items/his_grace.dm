//His Grace is a very special weapon granted only to traitor chaplains.
//When awakened, He thirsts for blood and begins ticking a "bloodthirst" counter.
//The wielder of His Grace is immune to stuns and gradually heals.
//If the wielder fails to feed His Grace in time, He will devour them and become incredibly aggressive.
//Leaving His Grace alone for some time will reset His thirst and put Him to sleep.
//Using His Grace effectively requires extreme speed and care.
/obj/item/his_grace
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Looking at it makes you feel uneasy."
	icon = 'icons/obj/storage.dmi'
	icon_state = "green"
	inhand_icon_state = "artistic_toolbox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 12
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	var/awakened = FALSE
	var/bloodthirst = HIS_GRACE_SATIATED
	var/prev_bloodthirst = HIS_GRACE_SATIATED
	var/force_bonus = 0
	var/ascended = FALSE
	var/victims_needed = 25
	var/ascend_bonus = 15

/obj/item/his_grace/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	SSpoints_of_interest.make_point_of_interest(src)
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(move_gracefully))
	update_appearance()

/obj/item/his_grace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))
	return ..()

/obj/item/his_grace/update_icon_state()
	icon_state = ascended ? "gold" : "green"
	inhand_icon_state = ascended ? "toolbox_gold" : "artistic_toolbox"
	return ..()

/obj/item/his_grace/update_overlays()
	. = ..()
	if(ascended)
		. += "triple_latch"
	else if(awakened)
		. += "single_latch_open"
	else
		. += "single_latch"

/obj/item/his_grace/attack_self(mob/living/user)
	if(!awakened)
		INVOKE_ASYNC(src, PROC_REF(awaken), user)

/obj/item/his_grace/attack(mob/living/M, mob/user)
	. = ..()
	if(!.)
		return

	if(awakened && M.stat)
		consume(M)

/obj/item/his_grace/CtrlClick(mob/user, list/params) //you can't pull his grace
	return

/obj/item/his_grace/examine(mob/user)
	. = ..()
	if(awakened)
		switch(bloodthirst)
			if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
				. += span_his_grace("[src] isn't very hungry. Not yet.")
			if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
				. += span_his_grace("[src] would like a snack.")
			if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
				. += span_his_grace("[src] is quite hungry now.")
			if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
				. += span_his_grace("[src] is openly salivating at the sight of you. Be careful.")
			if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
				. += "<span class='his_grace bold'>You walk a fine line. [src] is very close to devouring you.</span>"
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				. += "<span class='his_grace bold'>[src] is shaking violently and staring directly at you.</span>"
	else
		. += span_his_grace("[src] is latched closed.")

/obj/item/his_grace/relaymove(mob/living/user, direction) //Allows changelings, etc. to climb out of Him after they revive, provided He isn't active
	if(!awakened)
		user.forceMove(get_turf(src))
		user.visible_message(span_warning("[user] scrambles out of [src]!"), span_notice("You climb out of [src]!"))

/obj/item/his_grace/process(delta_time)
	if(!bloodthirst)
		drowse()
		return

	if(bloodthirst < HIS_GRACE_CONSUME_OWNER && !ascended)
		adjust_bloodthirst((1 + FLOOR(LAZYLEN(contents) * 0.5, 1)) * delta_time) //Maybe adjust this?
	else
		adjust_bloodthirst(1 * delta_time) //don't cool off rapidly once we're at the point where His Grace consumes all.

	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	if(istype(master) && (src in master.held_items))
		switch(bloodthirst)
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				master.visible_message(span_boldwarning("[src] turns on [master]!"), "<span class='his_grace big bold'>[src] turns on you!</span>")
				do_attack_animation(master, null, src)
				master.emote("scream")
				master.remove_status_effect(/datum/status_effect/his_grace)
				REMOVE_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
				master.Paralyze(60)
				master.adjustBruteLoss(master.maxHealth)
				playsound(master, 'sound/effects/splat.ogg', 100, FALSE)
			else
				master.apply_status_effect(/datum/status_effect/his_grace)
		return
	forceMove(get_turf(src)) //no you can't put His Grace in a locker you just have to deal with Him
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER)
		return
	if(bloodthirst >= HIS_GRACE_FALL_ASLEEP)
		drowse()
		return

	var/list/targets = list()
	for(var/mob/living/L in oview(2, src))
		targets += L

	if(!LAZYLEN(targets))
		return

	var/mob/living/L = pick(targets)
	step_to(src, L)

	if(Adjacent(L))
		if(!L.stat)
			L.visible_message(span_warning("[src] lunges at [L]!"), "<span class='his_grace big bold'>[src] lunges at you!</span>")
			do_attack_animation(L, null, src)
			playsound(L, 'sound/weapons/smash.ogg', 50, TRUE)
			playsound(L, 'sound/misc/desecration-01.ogg', 50, TRUE)
			L.adjustBruteLoss(force)
			adjust_bloodthirst(-5) //Don't stop attacking they're right there!
		else
			consume(L)

/obj/item/his_grace/proc/awaken(mob/user) //Good morning, Mr. Grace.
	if(awakened)
		return
	awakened = TRUE
	user.visible_message(span_boldwarning("[src] begins to rattle. He thirsts."), span_his_grace("You flick [src]'s latch up. You hope this is a good idea."))
	name = "His Grace"
	desc = "A bloodthirsty artifact created by a profane rite."
	gender = MALE
	adjust_bloodthirst(1)
	force_bonus = HIS_GRACE_FORCE_BONUS * LAZYLEN(contents)
	playsound(user, 'sound/effects/pope_entry.ogg', 100)
	update_appearance()
	move_gracefully()

/obj/item/his_grace/proc/move_gracefully()
	SIGNAL_HANDLER

	if(!awakened)
		return
	var/static/list/transforms
	if(!transforms)
		var/matrix/M1 = matrix()
		var/matrix/M2 = matrix()
		var/matrix/M3 = matrix()
		var/matrix/M4 = matrix()
		M1.Translate(-1, 0)
		M2.Translate(0, 1)
		M3.Translate(1, 0)
		M4.Translate(0, -1)
		transforms = list(M1, M2, M3, M4)

	animate(src, transform=transforms[1], time=0.2, loop=-1)
	animate(transform=transforms[2], time=0.1)
	animate(transform=transforms[3], time=0.2)
	animate(transform=transforms[4], time=0.3)

/obj/item/his_grace/proc/drowse() //Good night, Mr. Grace.
	if(!awakened || ascended)
		return
	var/turf/T = get_turf(src)
	T.visible_message(span_boldwarning("[src] slowly stops rattling and falls still, His latch snapping shut."))
	playsound(loc, 'sound/weapons/batonextend.ogg', 100, TRUE)
	name = initial(name)
	desc = initial(desc)
	animate(src, transform=matrix())
	gender = initial(gender)
	force = initial(force)
	force_bonus = initial(force_bonus)
	awakened = FALSE
	bloodthirst = 0
	update_appearance()

/obj/item/his_grace/proc/consume(mob/living/meal) //Here's your dinner, Mr. Grace.
	if(!meal)
		return
	var/victims = 0
	meal.visible_message(span_warning("[src] swings open and devours [meal]!"), "<span class='his_grace big bold'>[src] consumes you!</span>")
	meal.adjustBruteLoss(200)
	playsound(meal, 'sound/misc/desecration-02.ogg', 75, TRUE)
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	meal.forceMove(src)
	force_bonus += HIS_GRACE_FORCE_BONUS
	prev_bloodthirst = bloodthirst
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER)
		bloodthirst = max(LAZYLEN(contents), 1) //Never fully sated, and His hunger will only grow.
	else
		bloodthirst = HIS_GRACE_CONSUME_OWNER
	for(var/mob/living/C in contents)
		if(C.mind)
			victims++
	if(victims >= victims_needed)
		ascend()
	update_stats()

/obj/item/his_grace/proc/adjust_bloodthirst(amt)
	prev_bloodthirst = bloodthirst
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER && !ascended)
		bloodthirst = clamp(bloodthirst + amt, HIS_GRACE_SATIATED, HIS_GRACE_CONSUME_OWNER)
	else if(!ascended)
		bloodthirst = clamp(bloodthirst + amt, HIS_GRACE_CONSUME_OWNER, HIS_GRACE_FALL_ASLEEP)
	update_stats()

/obj/item/his_grace/proc/update_stats()
	REMOVE_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	switch(bloodthirst)
		if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
			if(HIS_GRACE_CONSUME_OWNER > prev_bloodthirst)
				master.visible_message(span_userdanger("[src] enters a frenzy!"))
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			ADD_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
			if(HIS_GRACE_STARVING > prev_bloodthirst)
				master.visible_message(span_boldwarning("[src] is starving!"), "<span class='his_grace big'>[src]'s bloodlust overcomes you. [src] must be fed, or you will become His meal.\
				[force_bonus < 15 ? " And still, His power grows.":""]</span>")
				force_bonus = max(force_bonus, 15)
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			ADD_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
			if(HIS_GRACE_FAMISHED > prev_bloodthirst)
				master.visible_message(span_warning("[src] is very hungry!"), "<span class='his_grace big'>Spines sink into your hand. [src] must feed immediately.\
				[force_bonus < 10 ? " His power grows.":""]</span>")
				force_bonus = max(force_bonus, 10)
			if(prev_bloodthirst >= HIS_GRACE_STARVING)
				master.visible_message(span_warning("[src] is now only very hungry!"), "<span class='his_grace big'>Your bloodlust recedes.</span>")
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			if(HIS_GRACE_HUNGRY > prev_bloodthirst)
				master.visible_message(span_warning("[src] is getting hungry."), "<span class='his_grace big'>You feel [src]'s hunger within you.\
				[force_bonus < 5 ? " His power grows.":""]</span>")
				force_bonus = max(force_bonus, 5)
			if(prev_bloodthirst >= HIS_GRACE_FAMISHED)
				master.visible_message(span_warning("[src] is now only somewhat hungry."), span_his_grace("[src]'s hunger recedes a little..."))
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			if(HIS_GRACE_PECKISH > prev_bloodthirst)
				master.visible_message(span_warning("[src] is feeling snackish."), span_his_grace("[src] begins to hunger."))
			if(prev_bloodthirst >= HIS_GRACE_HUNGRY)
				master.visible_message(span_warning("[src] is now only a little peckish."), "<span class='his_grace big'>[src]'s hunger recedes somewhat...</span>")
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			if(prev_bloodthirst >= HIS_GRACE_PECKISH)
				master.visible_message(span_warning("[src] is satiated."), "<span class='his_grace big'>[src]'s hunger recedes...</span>")
	force = initial(force) + force_bonus

/obj/item/his_grace/proc/ascend()
	if(ascended)
		return
	var/mob/living/carbon/human/master = loc
	force_bonus += ascend_bonus
	desc = "A legendary toolbox and a distant artifact from The Age of Three Powers. On its three latches engraved are the words \"The Sun\", \"The Moon\", and \"The Stars\". The entire toolbox has the words \"The World\" engraved into its sides."
	ascended = TRUE
	update_appearance()
	playsound(src, 'sound/effects/his_grace_ascend.ogg', 100)
	if(istype(master))
		master.update_held_items()
		master.visible_message("<span class='his_grace big bold'>Gods will be watching.</span>")
		name = "[master]'s mythical toolbox of three powers"
