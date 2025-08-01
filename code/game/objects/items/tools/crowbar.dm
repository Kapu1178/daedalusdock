TYPEINFO_DEF(/obj/item/crowbar)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	default_materials = list(/datum/material/iron=70)

/obj/item/crowbar
	name = "crowbar"
	desc = "A steel crowbar for gaining entry into places you should not be."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar_large"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	inhand_icon_state = "crowbar"
	worn_icon_state = "crowbar"

	usesound = 'sound/items/crowbar.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

	force = 14
	throwforce = 7
	throw_range = 5

	stamina_damage = 35
	stamina_cost = 12
	stamina_critical_chance = 10

	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound = 'sound/items/handling/crowbar_pickup.ogg'

	attack_verb_continuous = list("attacks", "bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("attack", "bash", "batter", "bludgeon", "whack")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	var/force_opens = FALSE

/obj/item/crowbar/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/crowbar/get_misssound()
	return pick('sound/weapons/swing/swing_crowbar.ogg', 'sound/weapons/swing/swing_crowbar2.ogg', 'sound/weapons/swing/swing_crowbar3.ogg')

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/red/suicide_act(mob/user)
	user.visible_message(span_suicide("[user]'s body turns limp and collapses to the ground as [user.p_they()] smashes [user.p_their()] head in with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/health/flatline.ogg', 50, FALSE, -1)
	return (BRUTELOSS)

TYPEINFO_DEF(/obj/item/crowbar/abductor)
	default_materials = list(/datum/material/iron = 5000, /datum/material/silver = 2500, /datum/material/plasma = 1000, /datum/material/titanium = 2000, /datum/material/diamond = 2000)

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	belt_icon_state = "crowbar_alien"
	toolspeed = 0.1


TYPEINFO_DEF(/obj/item/crowbar/pocket)
	default_materials = list(/datum/material/iron=50)

/obj/item/crowbar/pocket
	name = "compact crowbar"
	desc = "A small steel crowbar."
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_range = 7
	icon_state = "crowbar"
	toolspeed = 1.7

/obj/item/crowbar/heavy //from space ruin
	name = "heavy crowbar"
	desc = "It feels oddly heavy.."
	force = 20
	throw_range = 3
	icon_state = "crowbar_powergame"

/obj/item/crowbar/old
	name = "old crowbar"
	desc = "It's an old crowbar. They don't make 'em like they used to."
	throwforce = 10
	throw_speed = 1.5

/obj/item/crowbar/old/Initialize()
	. = ..()
	if(prob(50))
		icon_state = "crowbar_powergame"

TYPEINFO_DEF(/obj/item/crowbar/power)
	default_materials = list(/datum/material/iron = 4500, /datum/material/silver = 2500, /datum/material/titanium = 3500)

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "A set of jaws of life, compressed through the magic of science."
	icon_state = "jaws"
	inhand_icon_state = "jawsoflife"
	worn_icon_state = "jawsoflife"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.7
	force_opens = TRUE

/obj/item/crowbar/power/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between crowbar and wirecutters and gives feedback to the user.
 */
/obj/item/crowbar/power/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? TOOL_WIRECUTTER : TOOL_CROWBAR)
	balloon_alert(user, "attached [active ? "cutting" : "prying"]")
	playsound(user ? user : src, 'sound/items/change_jaws.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/crowbar/power/syndicate
	desc = "A re-engineered copy of Daedalus' standard jaws of life. Can be used to force open airlocks in its crowbar configuration."
	icon_state = "jaws_syndie"
	toolspeed = 0.5
	force_opens = TRUE

/obj/item/crowbar/power/examine()
	. = ..()
	. += " It's fitted with a [tool_behaviour == TOOL_CROWBAR ? "prying" : "cutting"] head."

/obj/item/crowbar/power/suicide_act(mob/user)
	if(tool_behaviour == TOOL_CROWBAR)
		user.visible_message(span_suicide("[user] is putting [user.p_their()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/items/jaws_pry.ogg', 50, TRUE, -1)
	else
		user.visible_message(span_suicide("[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!"))
		playsound(loc, 'sound/items/jaws_cut.ogg', 50, TRUE, -1)
		if(iscarbon(user))
			var/mob/living/carbon/suicide_victim = user
			var/obj/item/bodypart/target_bodypart = suicide_victim.get_bodypart(BODY_ZONE_HEAD)
			if(target_bodypart)
				target_bodypart.drop_limb()
				playsound(loc, SFX_DESECRATION, 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/crowbar/power/attack(mob/living/carbon/attacked_carbon, mob/user)
	if(istype(attacked_carbon) && attacked_carbon.handcuffed && tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message(span_notice("[user] cuts [attacked_carbon]'s restraints with [src]!"))
		qdel(attacked_carbon.handcuffed)
		return

	return ..()

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, simple but powerful."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	worn_icon_state = "crowbar"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5
