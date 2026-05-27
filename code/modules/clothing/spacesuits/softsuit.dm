	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	inhand_icon_state = "void"
	supports_variations_flags = NONE

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	inhand_icon_state = "void"
	desc = "A spacesuit older than you are."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)
	supports_variations_flags = NONE

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "old space helmet"
	desc = "A space helmet older than you are. Check it for cracks."
	icon_state = "void"
	inhand_icon_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "old space suit"
	icon_state = "void"
	inhand_icon_state = "void"
	desc = "A cumbersome spacesuit older than you are."
	slowdown = 1.2
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//EVA suit
TYPEINFO_DEF(/obj/item/clothing/suit/space/eva)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 50, ACID = 65)

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "spacemodern"
	inhand_icon_state = "s_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."

TYPEINFO_DEF(/obj/item/clothing/head/helmet/space/eva)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 50, ACID = 65)

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "spacebowl00"
	inhand_icon_state = "s_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	visor_flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	up = TRUE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_outer_range = 4
	light_power = 1
	light_on = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)

	base_icon_state = "spacebowl"
	var/lamp_state = FALSE //Whether the headlamp is on or off.

/obj/item/clothing/head/helmet/space/eva/Initialize(mapload)
	. = ..()
	visor_toggling()

/obj/item/clothing/head/helmet/space/eva/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][lamp_state][up]" //Updates icon based on the current conditions, such as if the light is on or if the visor is down.

/obj/item/clothing/head/helmet/space/eva/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_helmet_light))
		lamp_state = !lamp_state
		update_appearance(UPDATE_ICON_STATE)
		set_light_on(lamp_state)
		update_action_buttons()
	return ..()

/obj/item/clothing/head/helmet/space/eva/AltClick(mob/user)
	if(equipped_to == user && user.canUseTopic(src, USE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/eva/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_welding_screen))
		toggle_welding_screen(user)
		return

	return ..()

/obj/item/clothing/head/helmet/space/eva/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		playsound(src, 'sound/items/sheath.ogg', 50, TRUE)
	update_appearance()

/obj/item/clothing/head/helmet/space/eva/examine(mob/user)
	. = ..()
	. += span_info("You can start constructing a critter sized mecha with a [span_bold("cyborg leg")].")

/obj/item/clothing/head/helmet/space/eva/attackby(obj/item/attacked_with, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(attacked_with, /obj/item/bodypart/leg/left/robot) && !istype(attacked_with, /obj/item/bodypart/leg/right/robot))
		return
	if(equipped_to)
		user.balloon_alert(user, "drop the helmet first!")
		return
	user.balloon_alert(user, "leg attached")
	new /obj/item/bot_assembly/vim(loc)
	qdel(attacked_with)
	qdel(src)

	//Emergency suit
TYPEINFO_DEF(/obj/item/clothing/head/helmet/space/fragile)
	default_armor = list(BLUNT = 5, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, air-tight helmet meant to protect the user during emergency situations. It doesn't look very durable, and the headlamp mount is empty."
	icon_state = "spacebowl00"
	inhand_icon_state = "syndicate-helm-orange"
	strip_delay = 65

TYPEINFO_DEF(/obj/item/clothing/suit/space/fragile)
	default_armor = list(BLUNT = 5, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, air-tight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "spacemodern_emergency"
	inhand_icon_state = "syndicate-orange"
	slowdown = 2
	strip_delay = 65

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(!.)
		return

	if(!torn && prob(50))
		to_chat(owner, span_warning("[src] tears from the damage, breaking the air-tight seal!"))
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]."
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, TRUE)
		playsound(loc, 'sound/effects/refill.ogg', 50, TRUE)
