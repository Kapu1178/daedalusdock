/mob/living/simple_animal/crow
	name = "crow"
	desc = "They seem to know where you need them to go."
	icon = 'icons/mob/crow.dmi'

	icon_state = "crowe"
	icon_living = "crowe"
	icon_dead = "crowe"
	flip_on_death = TRUE

	density = FALSE
	health = 80
	maxHealth = 80
	pass_flags = PASSTABLE | PASSMOB

	speak_emote = list("caws")
	emote_hear = list("caws.", "clicks.", "gwahs.")
	emote_see = list("flutters their wings.", "pecks at the ground.")

	speak_chance = 40
	turns_per_move = 10

	melee_damage_upper = 10
	melee_damage_lower = 5

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently moves aside"
	response_disarm_simple = "gently move aside"
	response_harm_continuous = "swats"
	response_harm_simple = "swat"

	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_vis_effect = ATTACK_EFFECT_BITE

	friendly_verb_continuous = "preens"
	friendly_verb_simple = "preen"

	mob_size = MOB_SIZE_SMALL

	COOLDOWN_DECLARE(speech_cooldown)
	var/datum/proximity_monitor/advanced/crow/flee_monitor

/mob/living/simple_animal/crow/Initialize(mapload)
	. = ..()
	flee_monitor = new(src, 5)

	// Staggers out their movement.
	turns_since_move = rand(0, turns_per_move)

/mob/living/simple_animal/crow/Destroy()
	QDEL_NULL(flee_monitor)
	return ..()

/mob/living/simple_animal/crow/attacked_by(obj/item/attacking_item, mob/living/attacker, datum/special_attack/used_special)
	. = ..()
	if(. != MOB_ATTACKEDBY_MISS && (stat == CONSCIOUS))
		fly_away()

/mob/living/simple_animal/crow/handle_automated_movement()
	if(prob(80))
		return ..()

	var/turf/candidates = RANGE_TURFS(5, src)
	var/turf/target

	while(length(candidates))
		var/turf/T = pick_n_take(candidates)
		if(is_turf_safe(T))
			target = T
			break

	if(!target)
		return FALSE

	fly_to(target)
	return TRUE

/mob/living/simple_animal/crow/handle_automated_speech(override)
	if(!(prob(speak_chance) || override) || !COOLDOWN_FINISHED(src, speech_cooldown))
		return

	COOLDOWN_START(src, speech_cooldown, 4 SECONDS)

	var/length = length(emote_hear) + length(emote_see)
	var/hear_len = length(emote_hear)
	var/random_index = rand(1, length)

	var/list/static/sound_map = list(
		"caws." = list(
			'sound/voice/crow/idle1.ogg',
			'sound/voice/crow/idle2.ogg',
			'sound/voice/crow/idle3.ogg',
			'sound/voice/crow/idle4.ogg',
		)
	)

	var/performed_emote
	if(rand(1, length) <= hear_len)
		performed_emote = emote_hear[random_index]
		if(!sound_map[performed_emote])
			manual_emote(performed_emote)
	else
		performed_emote = emote_see[random_index - hear_len]
		if(!sound_map[performed_emote])
			manual_emote(performed_emote)

	var/sound_to_play = pick_safe(sound_map[performed_emote])
	if(sound_to_play)
		playsound(src, sound_to_play, 50, FALSE)

/mob/living/simple_animal/proc/fly_to(turf/destination)
	set waitfor = FALSE

	notransform = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = "flying"

	playsound(src, 'sound/voice/crow/flap2.ogg', 50, TRUE)

	var/turf/origin = get_turf(src)

	var/flight_height = 16
	var/target_pixel_x = (destination.x - origin.x) * world.icon_size
	var/target_pixel_y = (destination.y - origin.y) * world.icon_size
	var/flight_duration = get_dist_euclidean(origin, destination) * (0.2 SECONDS)

	animate(src, pixel_y = 16, time = 0.5 SECONDS, easing = EASE_IN|SINE_EASING)
	animate(pixel_x = target_pixel_x, pixel_y = target_pixel_y + flight_height, time = flight_duration, easing = EASE_IN|EASE_OUT|SINE_EASING)
	animate(pixel_y = target_pixel_y, time = 0.5 SECONDS, easing = EASE_OUT|SINE_EASING)

	sleep(flight_duration + 1 SECONDS)

	forceMove(destination)

	pixel_x = 0
	pixel_y = 0
	notransform = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	icon_state = icon_living

/mob/living/simple_animal/crow/proc/fly_away()
	set waitfor = FALSE

	notransform = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	QDEL_NULL(flee_monitor)

	var/direction = pick(1, -1)
	var/horizontal_dist = rand(7, 5 * world.icon_size)
	var/horizontal_time = round(Frand(2.5 SECONDS, 4 SECONDS), 0.1)

	icon_state = "flying"
	layer = FLY_LAYER //conveniently named

	dir = direction ? EAST : WEST

	var/vertical_ease = pick(EASE_IN|BACK_EASING, QUAD_EASING|EASE_OUT)
	var/vertical_dist = 10 * world.icon_size
	var/vertical_time = round(Frand(2.5 SECONDS, 4 SECONDS), 0.1)

	var/fade_delay = min(vertical_time, horizontal_time) - (1 SECOND)
	var/fade_duration = round(Frand(1 SECOND, min(3 SECONDS, vertical_time - fade_delay, horizontal_time - fade_delay)))

	var/static/list/fly_away_sounds = list(
		'sound/voice/crow/pain1.ogg',
		'sound/voice/crow/pain2.ogg',
		'sound/voice/crow/alert1.ogg',
		'sound/voice/crow/alert2.ogg',
		'sound/voice/crow/alert3.ogg',
		'sound/voice/crow/flap2.ogg'
	)

	playsound(src, pick(fly_away_sounds), 50, FALSE)

	animate(src, pixel_x = horizontal_dist * direction, time = horizontal_time, easing = EASE_OUT|QUAD_EASING)
	animate(src, pixel_y = vertical_dist, time = vertical_time, easing = vertical_ease, flags = ANIMATION_PARALLEL)
	animate(src, delay = fade_delay, alpha = 0, time = fade_duration, flags = ANIMATION_PARALLEL)

	QDEL_IN(src, fade_delay + fade_duration)

/datum/proximity_monitor/advanced/crow
	edge_is_a_field = TRUE

	var/datum/sound_token/token

/datum/proximity_monitor/advanced/crow/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(istype(movable, /mob/living/simple_animal/crow) || astype(host, /mob/living/simple_animal/crow).notransform)
		return

	if(prob(80 / get_dist(host, movable)) && (movable in viewers(5, host)))
		astype(host, /mob/living/simple_animal/crow).fly_away()
