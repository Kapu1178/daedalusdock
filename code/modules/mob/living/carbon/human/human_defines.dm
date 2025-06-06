/// Any humanoid (non-Xeno) mob, such as humans, plasmamen, lizards.
/mob/living/carbon/human
	name = "Unknown"
	real_name = "Unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "human_basic"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	flags_1 = parent_type::flags_1 | PREVENT_CONTENTS_EXPLOSION_1

	hud_possible = list(
		HEALTH_HUD = 'icons/mob/huds/med_hud.dmi',
		STATUS_HUD = 'icons/mob/huds/hud.dmi',
		ID_HUD = 'icons/mob/huds/hud.dmi',
		WANTED_HUD = 'icons/mob/huds/hud.dmi',
		IMPLOYAL_HUD = 'icons/mob/huds/hud.dmi',
		IMPCHEM_HUD = 'icons/mob/huds/hud.dmi',
		IMPTRACK_HUD = 'icons/mob/huds/hud.dmi',
		GLAND_HUD = 'icons/mob/huds/hud.dmi',
		SENTIENT_PATHOGEN_HUD = 'icons/mob/huds/hud.dmi',
	)

	hud_type = /datum/hud/human
	//pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = 0
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	can_be_shoved_into = TRUE
	held_w_class = WEIGHT_CLASS_BULKY

	//Hair colour and style
	var/hair_color = "#000000"
	var/hairstyle = "Bald"

	///Colours used for hair and facial hair gradients.
	var/list/grad_color
	///Styles used for hair and facial hair gradients.
	var/list/grad_style

	//Facial hair colour and style
	var/facial_hair_color = "#000000"
	var/facial_hairstyle = "Shaved"

	//Eye colour
	var/eye_color_left = "#000000"
	var/eye_color_right = "#000000"
	/// Var used to keep track of a human mob having a heterochromatic right eye. To ensure prefs don't overwrite shit
	var/eye_color_heterochromatic = FALSE
	var/sclera_color = ""

	var/skin_tone = "caucasian1" //Skin tone

	var/lip_style = null //no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30 //Player's age

	//consider updating /mob/living/carbon/human/copy_clothing_prefs() if adding more of these
	var/underwear = "Nude" //Which underwear the player wants
	var/underwear_color = "#000000"
	var/undershirt = "Nude" //Which undershirt the player wants
	var/socks = "Nude" //Which socks the player wants
	var/jumpsuit_style = PREF_SUIT //suit/skirt

	//Equipment slots
	var/obj/item/clothing/wear_suit = null
	var/obj/item/clothing/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	/// What types of mobs are allowed to ride/buckle to this mob
	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/slime, /mob/living/simple_animal/parrot))
	var/lastpuke = 0
	var/account_id

	var/hardcore_survival_score = 0
	/// Which body type to use
	var/physique = MALE

	/// How many "units of blood" we have on our hands
	var/blood_in_hands = 0

	/// The core temperature of the human compaired to the skin temp of the body
	var/coretemperature = BODYTEMP_NORMAL

	///human specific screwyhuds from hallucinations (define key (bodypart) to int value (severity)) - see /datum/hallucination/fake_health_doll
	var/hal_screwydoll
	/// When an braindead player has their equipment fiddled with, we log that info here for when they come back so they know who took their ID while they were DC'd for 30 seconds
	var/list/afk_thefts

	///A lazylist of preference-applied appearance mods present on this human. Type:Instance
	var/list/appearance_mods

	var/list/time_of_death_stats
