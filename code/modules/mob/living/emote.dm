
/* EMOTE DATUMS */
/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/brain)

/// The time it takes for the blush visual to be removed
#define BLUSH_DURATION 5.2 SECONDS

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes."
	/// Timer for the blush visual to wear off
	var/blush_timer = TIMER_ID_NULL

/datum/emote/living/blush/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/living_user = user
		ADD_TRAIT(living_user, TRAIT_BLUSHING, "[type]")
		living_user.update_body()

		// Use a timer to remove the blush effect after the BLUSH_DURATION has passed
		var/list/key_emotes = GLOB.emote_list["blush"]
		for(var/datum/emote/living/blush/living_emote in key_emotes)
			// The existing timer restarts if it's already running
			blush_timer = addtimer(CALLBACK(living_emote, PROC_REF(end_blush), living_user), BLUSH_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/emote/living/blush/proc/end_blush(mob/living/living_user)
	if(!QDELETED(living_user))
		REMOVE_TRAIT(living_user, TRAIT_BLUSHING, "[type]")
		living_user.update_body()

#undef BLUSH_DURATION

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."
	hands_use_check = TRUE

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/burp/get_sound(mob/living/user)
	if(iscarbon(user))
		if(user.gender == MALE)
			return 'sound/emotes/male/burp_m.ogg'
		return 'sound/emotes/female/burp_f.ogg'

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/cross
	key = "cross"
	key_third_person = "crosses"
	message = "crosses their arms."
	hands_use_check = TRUE

/datum/emote/living/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Unconscious(40)

/datum/emote/living/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/cough/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_SOOTHED_THROAT))
		return FALSE

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily."
	hands_use_check = TRUE

/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	message = "seizes up and falls limp, their eyes dead and lifeless..."
	message_robot = "gives one shrill beep before falling lifeless."
	message_AI = "screeches, its screen flickering as its systems slowly halt."
	message_alien = "lets out a waning guttural screech, and collapses onto the floor..."
	message_larva = "lets out a sickly hiss of air and falls limply to the floor..."
	message_monkey = "lets out a faint chimper as it collapses and stops moving..."
	message_simple = "stops moving..."
	message_ipc =  "gives one shrill beep before falling lifeless."
	cooldown = (15 SECONDS)
	stat_allowed = UNCONSCIOUS

/datum/emote/living/deathgasp/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/simple_animal/S = user
	if(istype(S) && S.deathmessage)
		message_simple = S.deathmessage
	. = ..()
	message_simple = initial(message_simple)
	if(.)
		if(isliving(user))
			var/mob/living/L = user
			if(!L.can_speak_vocal() || L.getOxyLoss() >= 50)
				return //stop the sound if oxyloss too high/cant speak
		if(!user.deathsound)
			if(!ishuman(user))
				return
			var/mob/living/carbon/human/H = user

			playsound(H, H.dna?.species.get_deathgasp_sound(H), 100, 0)
			return
		playsound(user, user.deathsound, 200, TRUE, TRUE)

/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools."

/datum/emote/living/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."

/datum/emote/living/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.SetSleeping(200)

/datum/emote/living/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings."
	hands_use_check = TRUE
	var/wing_time = 20

/datum/emote/living/flap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/open = FALSE
		var/obj/item/organ/wings/functional/wings = H.getorganslot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(istype(wings))
			if(wings.wings_open)
				open = TRUE
				wings.close_wings()
			else
				wings.open_wings()
			addtimer(CALLBACK(wings, open ? TYPE_PROC_REF(/obj/item/organ/wings/functional, open_wings) : TYPE_PROC_REF(/obj/item/organ/wings/functional, close_wings)), wing_time)

/datum/emote/living/flap/aflap
	key = "aflap"
	key_third_person = "aflaps"
	message = "flaps their wings ANGRILY!"
	hands_use_check = TRUE
	wing_time = 10

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns."

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/gasp/get_sound(mob/living/user, involuntary)
	if(!iscarbon(user))
		return

	if(user.gender == MALE)
		return pick(
			'sound/emotes/male/gasp_m1.ogg',
			'sound/emotes/male/gasp_m3.ogg',
			'sound/emotes/male/gasp_m4.ogg',
			'sound/emotes/male/gasp_m5.ogg',
		)
	else
		return pick(
			'sound/emotes/female/gasp_f1.ogg',
			'sound/emotes/female/gasp_f4.ogg',
			'sound/emotes/female/gasp_f5.ogg',
			'sound/emotes/female/gasp_f6.ogg',
		)


/datum/emote/living/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	message_mime = "giggles silently!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins."

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans!"
	message_mime = "appears to groan!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces."

/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps!"
	hands_use_check = TRUE

/datum/emote/living/kiss
	key = "kiss"
	key_third_person = "kisses"
	cooldown = 3 SECONDS

/datum/emote/living/kiss/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/kiss_type = /obj/item/hand_item/kisser

	if(HAS_TRAIT(user, TRAIT_KISS_OF_DEATH))
		kiss_type = /obj/item/hand_item/kisser/death

	var/obj/item/kiss_blower = new kiss_type(user)
	if(user.put_in_hands(kiss_blower))
		to_chat(user, span_notice("You ready your kiss-blowing hand."))
	else
		qdel(kiss_blower)
		to_chat(user, span_warning("You're incapable of blowing a kiss in your current state."))

/datum/emote/living/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently!"
	emote_type = EMOTE_AUDIBLE
	audio_cooldown = 5 SECONDS
	vary = TRUE

/datum/emote/living/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		return !C.silent

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(!ishuman(user) || user.mind?.miming)
		return null

	var/mob/living/carbon/human/H = user
	if(H.dna.species.id == SPECIES_HUMAN)
		if(user.gender == FEMALE)
			return 'sound/voice/human/womanlaugh.ogg'
		else
			return pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	if(H.dna.species.id == SPECIES_MOTH)
		return 'sound/emotes/mothlaugh.ogg'

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "looks."
	message_param = "looks at %t."

/datum/emote/living/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods."
	message_param = "nods at %t."

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points."
	message_param = "points at %t."
	hands_use_check = TRUE

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.usable_hands == 0)
			if(H.usable_legs != 0)
				message_param = "tries to point at %t with a leg, [span_userdanger("falling down")] in the process!"
				H.Paralyze(20)
			else
				message_param = "[span_userdanger("bumps [user.p_their()] head on the ground")] trying to motion towards %t."
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
	return ..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts."

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams."
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human) //Humans get specialized scream.

/datum/emote/living/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(!intentional && isanimal(user))
		return "makes a loud and pained whimper."

/datum/emote/living/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls."

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head."

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."

/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/sigh/get_sound(mob/living/user)
	if(iscarbon(user))
		if(user.gender == MALE)
			return 'sound/emotes/male/male_sigh.ogg'
		return 'sound/emotes/female/female_sigh.ogg'

/datum/emote/living/clap1
	key = "clap1"
	key_third_person = "claps once"
	message = "claps once."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/clap1/get_sound(mob/living/user)
	return pick('sound/emotes/claponce2.ogg')

/datum/emote/living/clap1/can_run_emote(mob/living/carbon/user, status_check = TRUE, intentional)
	if(user.usable_hands < 2)
		return FALSE
	return ..()

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down."

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles."

/datum/emote/living/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly."

/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/sniff/get_sound(mob/living/user)
	if(iscarbon(user))
		if(user.gender == MALE)
			return 'sound/emotes/male/male_sniff.ogg'
		return 'sound/emotes/female/female_sniff.ogg'

/datum/emote/living/carbon/human/sniff/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/mob/living/L = user
		COOLDOWN_RESET(L, smell_time)
		L.handle_smell()

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	message_mime = "sleeps soundly."
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS
	vary = TRUE
	sound = 'sound/emotes/snore.ogg'

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares."
	message_param = "stares at %t."

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms."

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks down sadly."

/datum/emote/living/surrender
	key = "surrender"
	key_third_person = "surrenders"
	message = "puts their hands on their head and falls to the ground, they surrender%s!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/surrender/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Paralyze(200)

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily."

/datum/emote/living/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "tilts their head to the side."
	message_AI = "tilts the image on their display."

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles in fear!"

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently."

/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "twitches."

/datum/emote/living/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers."
	message_mime = "appears hurt."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "smiles weakly."

/// The base chance for your yawn to propagate to someone else if they're on the same tile as you
#define YAWN_PROPAGATE_CHANCE_BASE 60
/// The base chance for your yawn to propagate to someone else if they're on the same tile as you
#define YAWN_PROPAGATE_CHANCE_DECAY 10

/datum/emote/living/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE
	cooldown = 3 SECONDS

/datum/emote/living/yawn/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!. || !isliving(user))
		return

	if(!TIMER_COOLDOWN_CHECK(user, COOLDOWN_YAWN_PROPAGATION))
		TIMER_COOLDOWN_START(user, COOLDOWN_YAWN_PROPAGATION, cooldown * 3)

	var/mob/living/carbon/carbon_user = user
	if(istype(carbon_user) && ((carbon_user.wear_mask?.flags_inv & HIDEFACE) || carbon_user.head?.flags_inv & HIDEFACE))
		return // if your face is obscured, skip propagation

	var/propagation_distance = user.client ? 5 : 2 // mindless mobs are less able to spread yawns

	for(var/mob/living/iter_living in view(user, propagation_distance))
		if(IS_DEAD_OR_INCAP(iter_living) || TIMER_COOLDOWN_CHECK(user, COOLDOWN_YAWN_PROPAGATION))
			continue

		var/dist_between = get_dist(user, iter_living)
		var/recently_examined = FALSE // if you yawn just after someone looks at you, it forces them to yawn as well. Tradecraft!

		if(iter_living.client)
			var/examine_time = LAZYACCESS(iter_living.client?.recent_examines, user)
			if(examine_time && (world.time - examine_time < YAWN_PROPAGATION_EXAMINE_WINDOW))
				recently_examined = TRUE

		if(!recently_examined && !prob(YAWN_PROPAGATE_CHANCE_BASE - (YAWN_PROPAGATE_CHANCE_DECAY * dist_between)))
			continue

		var/yawn_delay = rand(0.25 SECONDS, 0.75 SECONDS) * dist_between
		addtimer(CALLBACK(src, PROC_REF(propagate_yawn), iter_living), yawn_delay)

/// This yawn has been triggered by someone else yawning specifically, likely after a delay. Check again if they don't have the yawned recently trait
/datum/emote/living/yawn/proc/propagate_yawn(mob/user)
	if(!istype(user) || TIMER_COOLDOWN_CHECK(user, COOLDOWN_YAWN_PROPAGATION))
		return
	user.emote("yawn")

#undef YAWN_PROPAGATE_CHANCE_BASE
#undef YAWN_PROPAGATE_CHANCE_DECAY

/datum/emote/living/gurgle
	key = "gurgle"
	key_third_person = "gurgles"
	message = "makes an uncomfortable gurgle."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null

/datum/emote/living/custom/can_run_emote(mob/user, status_check, intentional)
	. = ..() && intentional

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, span_danger("Invalid emote."))
		return TRUE
	return FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	var/custom_emote
	var/custom_emote_type
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	if(is_banned_from(user.ckey, "Emote"))
		to_chat(user, span_boldwarning("You cannot send custom emotes (banned)."))
		return FALSE
	else if(QDELETED(user))
		return FALSE
	else if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, span_boldwarning("You cannot send IC messages (muted)."))
		return FALSE
	else if(!params)
		custom_emote = copytext(sanitize(input("Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
			switch(type)
				if("Visible")
					custom_emote_type = EMOTE_VISIBLE
				if("Hearable")
					custom_emote_type = EMOTE_AUDIBLE
				else
					tgui_alert(usr,"Unable to use this emote, must be either hearable or visible.")
					return
	else
		custom_emote = params
		if(type_override)
			custom_emote_type = type_override
	message = custom_emote
	emote_type = custom_emote_type
	. = ..()
	message = null
	emote_type = EMOTE_VISIBLE

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	return message

/datum/emote/living/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps."
	message_param = "beeps at %t."
	sound = 'sound/machines/twobeep.ogg'
	mob_type_allowed_typecache = list(/mob/living/brain, /mob/living/silicon)
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/swear
	key = "swear"
	key_third_person = "swears"
	message = "says a swear word!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'sound/voice/snap.ogg'

/datum/emote/living/snap2
	key = "snap2"
	key_third_person = "snaps twice"
	message = "snaps twice."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'sound/voice/snap2.ogg'

/datum/emote/living/snap3
	key = "snap3"
	key_third_person = "snaps thrice"
	message = "snaps thrice."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	hands_use_check = TRUE
	vary = TRUE
	sound = 'sound/voice/snap3.ogg'

