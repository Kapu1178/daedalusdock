/*
 * Contains:
 * Fire protection
 * Bomb protection
 * Radiation protection
 */

/*
 * Fire protection
 */

TYPEINFO_DEF(/obj/item/clothing/suit/fire)
	default_armor = list(BLUNT = 15, PUNCTURE = 5, SLASH = 0, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 10, FIRE = 100, ACID = 50)

/obj/item/clothing/suit/fire
	name = "emergency firesuit"
	desc = "A suit that helps protect against fire and heat."
	icon_state = "fire"
	zmm_flags = ZMM_MANGLE_PLANES
	inhand_icon_state = "ro_suit"
	w_class = WEIGHT_CLASS_BULKY
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/extinguisher, /obj/item/crowbar)
	slowdown = 1
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/fire/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = 90)

/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	inhand_icon_state = "firefighter"

/obj/item/clothing/suit/fire/heavy
	name = "heavy firesuit"
	desc = "An old, bulky thermal protection suit."
	icon_state = "thermal"
	inhand_icon_state = "ro_suit"
	slowdown = 1.5

/obj/item/clothing/suit/fire/atmos
	name = "firesuit"
	desc = "An expensive firesuit that protects against even the most deadly of station fires. Designed to protect even if the wearer is set aflame."
	icon_state = "atmos_firesuit"
	inhand_icon_state = "firesuit_atmos"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/*
 * Bomb protection
 */
TYPEINFO_DEF(/obj/item/clothing/head/bomb_hood)
	default_armor = list(BLUNT = 20, PUNCTURE = 0, SLASH = 0, LASER = 20, ENERGY = 30, BOMB = 100, BIO = 0, FIRE = 80, ACID = 50)

/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEFACE|HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 70
	equip_delay_other = 70
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE


TYPEINFO_DEF(/obj/item/clothing/suit/bomb_suit)
	default_armor = list(BLUNT = 20, PUNCTURE = 0, SLASH = 0, LASER = 20, ENERGY = 30, BOMB = 100, BIO = 0, FIRE = 80, ACID = 50)

/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	inhand_icon_state = "bombsuit"
	w_class = WEIGHT_CLASS_BULKY
	permeability_coefficient = 0.01
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	flags_inv = HIDEJUMPSUIT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = NONE


/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuit_sec"
	inhand_icon_state = "bombsuit_sec"

/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuit_sec"
	inhand_icon_state = "bombsuit_sec"
	allowed = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/restraints/handcuffs)


/obj/item/clothing/head/bomb_hood/white
	icon_state = "bombsuit_white"
	inhand_icon_state = "bombsuit_white"

/obj/item/clothing/suit/bomb_suit/white
	icon_state = "bombsuit_white"
	inhand_icon_state = "bombsuit_white"

/*
* Radiation protection
*/

TYPEINFO_DEF(/obj/item/clothing/head/radiation)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, FIRE = 30, ACID = 30)

/obj/item/clothing/head/radiation
	name = "radiation hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. The label reads, 'Made with lead. Please do not consume insulation.'"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	strip_delay = 60
	equip_delay_other = 60
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/head/radiation/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

TYPEINFO_DEF(/obj/item/clothing/suit/radiation)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, FIRE = 30, ACID = 30)

/obj/item/clothing/suit/radiation
	name = "radiation suit"
	desc = "A suit that protects against radiation. The label reads, 'Made with lead. Please do not consume insulation.'"
	icon_state = "rad"
	zmm_flags = ZMM_MANGLE_PLANES
	inhand_icon_state = "rad_suit"
	w_class = WEIGHT_CLASS_BULKY
	permeability_coefficient = 0.5
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/geiger_counter)
	slowdown = 1.5
	strip_delay = 60
	equip_delay_other = 60
	flags_inv = HIDEJUMPSUIT
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/suit/radiation/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/radiation/worn_overlays(mob/living/carbon/human/wearer, mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = 90)
