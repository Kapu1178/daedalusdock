/* Kitchen tools
 * Contains:
 * Fork
 * Kitchen knives
 * Rolling Pins
 * Plastic Utensils
 */

#define PLASTIC_BREAK_PROBABILITY 25

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'

/obj/item/kitchen/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_APC_SHOCKING, INNATE_TRAIT)

TYPEINFO_DEF(/obj/item/kitchen/fork)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	default_materials = list(/datum/material/iron=80)

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 4
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 1.5
	throw_range = 5
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("attacks", "stabs", "pokes")
	attack_verb_simple = list("attack", "stab", "poke")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette
	custom_price = PAYCHECK_ASSISTANT * 0.7

/obj/item/kitchen/fork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] stabs \the [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/kitchen/fork/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return NONE


	if(!forkload)
		return NONE

	if(interacting_with == user)
		interacting_with.visible_message(span_notice("[user] eats a delicious forkful of omelette!"))
		interacting_with.reagents.add_reagent(forkload.type, 1)
	else
		interacting_with.visible_message(span_notice("[user] feeds [interacting_with] a delicious forkful of omelette!"))
		interacting_with.reagents.add_reagent(forkload.type, 1)
	icon_state = "fork"
	forkload = null
	return ITEM_INTERACT_SUCCESS

TYPEINFO_DEF(/obj/item/kitchen/fork/plastic)
	default_materials = list(/datum/material/plastic=80)

/obj/item/kitchen/fork/plastic
	name = "plastic fork"
	desc = "Really takes you back to highschool lunch."
	icon_state = "plastic_fork"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	custom_price = PAYCHECK_ASSISTANT * 0.2

/obj/item/kitchen/fork/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

/obj/item/knife/kitchen
	name = "kitchen knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."

TYPEINFO_DEF(/obj/item/knife/plastic)
	default_materials = list(/datum/material/plastic = 100)

/obj/item/knife/plastic
	name = "plastic knife"
	icon_state = "plastic_knife"
	inhand_icon_state = "knife"
	desc = "A very safe, barely sharp knife made of plastic. Good for cutting food and not much else."
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_range = 5
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	sharpness = SHARP_EDGED
	custom_price = PAYCHECK_ASSISTANT * 0.2

/obj/item/knife/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

TYPEINFO_DEF(/obj/item/kitchen/rollingpin)
	default_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	worn_icon_state = "rolling_pin"

	force = 8
	throwforce = 10
	throw_speed = 1.5
	throw_range = 7
	stamina_damage = 40
	stamina_cost = 15
	stamina_critical_chance = 2

	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	custom_price = PAYCHECK_ASSISTANT * 1.5
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
/* Trays  moved to /obj/item/storage/bag */

TYPEINFO_DEF(/obj/item/kitchen/spoon)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	default_materials = list(/datum/material/iron=120)

/obj/item/kitchen/spoon
	name = "spoon"
	desc = "Just be careful your food doesn't melt the spoon first."
	icon_state = "spoon"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	force = 2
	throw_speed = 1.5
	throw_range = 5
	attack_verb_simple = list("whack", "spoon", "tap")
	attack_verb_continuous = list("whacks", "spoons", "taps")
	custom_price = PAYCHECK_ASSISTANT * 0.7
	tool_behaviour = TOOL_MINING
	toolspeed = 25 // Literally 25 times worse than the base pickaxe

TYPEINFO_DEF(/obj/item/kitchen/spoon/plastic)
	default_materials = list(/datum/material/plastic=120)

/obj/item/kitchen/spoon/plastic
	name = "plastic spoon"
	icon_state = "plastic_spoon"
	force = 0
	custom_price = PAYCHECK_ASSISTANT * 0.2
	toolspeed = 75 // The plastic spoon takes 5 minutes to dig through a single mineral turf... It's one, continuous, breakable, do_after...

/obj/item/kitchen/spoon/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

TYPEINFO_DEF(/obj/item/kitchen/spatula)
	default_materials = list(/datum/material/iron = 80, /datum/material/plastic = 40)

/obj/item/kitchen/spatula
	name = "spatula"
	desc = "Used to move hot food from a griddle onto a plate or tray, instead of using your own hands like some sort of animal."
	icon_state = "spatula"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	throw_speed = 1.5
	throw_range = 5
	attack_verb_simple = list("smack", "thwack", "slap")
	attack_verb_continuous = list("smacks", "thwacks", "slaps")

#undef PLASTIC_BREAK_PROBABILITY
