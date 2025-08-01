TYPEINFO_DEF(/obj/item/singularityhammer)
	default_armor = list(BLUNT = 50, PUNCTURE = 50, SLASH = 0, LASER = 50, ENERGY = 0, BOMB = 50, BIO = 0, FIRE = 100, ACID = 100)

/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."

	icon_state = "singularity_hammer0"
	base_icon_state = "singularity_hammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	worn_icon_state = "singularity_hammer"

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK

	force = 5
	force_wielded = 20
	throwforce = 15
	throw_range = 1

	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	///Is it able to pull shit right now?
	var/charged = TRUE

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	icon_state_wielded = "[base_icon_state][1]"
	AddElement(/datum/element/kneejerk)

/obj/item/singularityhammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/singularityhammer/proc/recharge()
	charged = TRUE

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/X in orange(5,pull))
		if(ismovable(X))
			var/atom/movable/A = X
			if(A == wielder)
				continue
			if(isliving(A))
				var/mob/living/vortexed_mob = A
				if(vortexed_mob.mob_negates_gravity())
					continue
				else
					vortexed_mob.Paralyze(2 SECONDS)
			if(!A.anchored && !isobserver(A))
				step_towards(A,pull)
				step_towards(A,pull)
				step_towards(A,pull)

/obj/item/singularityhammer/afterattack(atom/target, mob/user, list/modifiers)
	if(!wielded || !charged)
		return

	charged = FALSE

	if(istype(target, /mob/living))
		var/mob/living/Z = target
		Z.take_bodypart_damage(20,0)

	playsound(user, 'sound/weapons/marauder.ogg', 50, TRUE)

	var/turf/turf = get_turf(target)
	vortex(turf,user)
	addtimer(CALLBACK(src, PROC_REF(recharge)), 100)

/obj/item/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	base_icon_state = "mjollnir"
	worn_icon_state = "mjolnir"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK

	force = 5
	force_wielded = 25
	throwforce = 30
	throw_range = 7

	w_class = WEIGHT_CLASS_HUGE

/obj/item/mjollnir/Initialize(mapload)
	. = ..()
	icon_state_wielded = "[base_icon_state][1]"

/obj/item/mjollnir/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/mjollnir/proc/shock(mob/living/target)
	target.Stun(1.5 SECONDS)
	target.Knockdown(10 SECONDS)
	var/datum/effect_system/lightning_spread/s = new /datum/effect_system/lightning_spread
	s.set_up(5, 1, target.loc)
	s.start()
	target.visible_message(span_danger("[target.name] is shocked by [src]!"), \
		span_userdanger("You feel a powerful shock course through your body sending you flying!"), \
		span_hear("You hear a heavy electrical crack!"))
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)
	return

/obj/item/mjollnir/attack(mob/living/M, mob/user)
	. = ..()
	if(.)
		return

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	if(wielded)
		shock(M)

/obj/item/mjollnir/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		shock(hit_atom)
