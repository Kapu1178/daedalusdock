/obj/effect/fakemob/king
	name = "Playwright"
	icon = 'goon/icons/obj/kinginyellow.dmi'
	icon_state = "kingyellow"

	speech_span = SPAN_ITALICS
	light_system = OVERLAY_LIGHT
	light_outer_range =  1.1
	light_color = "#FFFFFF"

	dialogue = list(
		"Birdies, birdies... gather ye here, 'round the marble nest.",
		"It's all coming to a close now.",
		"Tequila Sunset. Poetic, is it not?",
		"It's going wrong.",
		"Se ei ole mikään kauhupaikka",
		"I cannot know before it's done if I'll live or I shall die.",
		"A man chooses, a slave obeys. What of a man who is a slave to himself?",
		"Playing \"Good Citizen\", I've never tried.",
		"The bolder the dream, the more surely it becomes dust when the moment is lost.",
		"A slave. You call him a slave.",
		"Good friends are too few.",
		"I think tackling the fourth wall so directly is kind of tasteless in the modern world.",
		"Dreams are fine, but I need bread.",
		"You will be the death of me.",
		"Let me occupy your mind, as you do mine.",
		"How do you wake someone up from inside a dream?",
	)

	var/dialogues_said = 0

	var/is_falling = FALSE

/obj/effect/fakemob/king/Initialize(mapload)
	. = ..()
	real_mob.set_real_name(name)
	shuffle_inplace(dialogue)

/obj/effect/fakemob/king/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	long_live_the_king()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/effect/fakemob/king/proc/long_live_the_king(book_ending = FALSE)
	set waitfor = FALSE
	if(is_falling)
		return

	is_falling = TRUE

	var/matrix/target_transform = matrix().Translate(0, -24)

	animate(src, transform = target_transform, time = 0.3 SECONDS)

	sleep(0.3 SECONDS)

	qdel(src)
	src = null

	var/sound/screm = sound('sound/voice/iamfallingdownpleasehelpme.ogg', 0, 0, 0, 50)
	for(var/mob/player in GLOB.player_list)
		if(player.can_hear() && istype(get_area(player), /area/station/testmap/tower_of_babel))
			SEND_SOUND(player, screm)

	sleep(2.3 SECONDS) // About the time the thud starts

	var/turf/crown_loc = get_turf(locate(/obj/effect/landmark/king_death) in GLOB.landmarks_list)
	if(book_ending)
		new /obj/item/clothing/head/crown/kiy(crown_loc)
		new /obj/effect/spotlight(crown_loc)
		SSnowhere.got_book_ending = TRUE
	else
		crown_loc.ChangeTurf(/turf/open/floor/fakespace)
		crown_loc.overlays += global.fullbright_overlay
		crown_loc.luminosity = TRUE

		var/list/nearby_turfs = RANGE_TURFS(1, crown_loc)
		nearby_turfs -= crown_loc
		for(var/i in 1 to 4)
			var/turf/T = pick_n_take(nearby_turfs)
			T.ChangeTurf(/turf/open/floor/fakespace)
			T.overlays += global.fullbright_overlay
			T.luminosity = TRUE

	for(var/mob/living/viewer in viewers(crown_loc))
		viewer.flash_act(visual = TRUE, type = /atom/movable/screen/fullscreen/flash/black)

	//sleep(1.9 SECONDS) // The time it takes for all of the echo and reverb to end.
	sleep(5 SECONDS)
	var/sound/S = sound('goon/sounds/void/Void_Song.ogg', channel = CHANNEL_VOID_SOUND, volume = 50)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		SEND_SOUND(H, S)

	sleep(1 MINUTE)
	SSticker.end_round()

/obj/effect/fakemob/king/skinwalk(mob/living/puppet)
	return

/obj/effect/fakemob/king/handle_dialogue(mob/living/user)
	. = ..()
	if(!.)
		return

	dialogues_said++
	if(dialogues_said == 4)
		dialogue = list("It is time for you to leave. I cannot go with you.")

/obj/effect/spotlight

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = O_LIGHTING_VISUAL_PLANE
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

/obj/effect/spotlight/Initialize(mapload)
	. = ..()
	icon = 'icons/effects/light_overlays/light_96.dmi'
	icon_state = "cone"
	pixel_x = -32
	pixel_y = -32

/obj/item/clothing/head/crown/kiy
	desc = "Engraved on the side is one word: <i>\"Ktisis\"</i>"
