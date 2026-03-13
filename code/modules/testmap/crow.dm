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

	speak_chance = 2 //1% (1 in 100) chance every tick; So about once per 150 seconds, assuming an average tick is 1.5s
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

	var/datum/proximity_monitor/advanced/crow/flee_monitor

/mob/living/simple_animal/crow/Initialize(mapload)
	. = ..()
	flee_monitor = new(src, 5)

/mob/living/simple_animal/crow/Destroy()
	QDEL_NULL(flee_monitor)
	return ..()

/mob/living/simple_animal/crow/proc/fly_away()
	notransform = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/direction = pick(1, -1)
	var/horizontal_dist = rand(7, 5 * world.icon_size)
	var/horizontal_time = round(Frand(1 SECOND, 5 SECONDS), 0.1)

	icon_state = "flying"
	layer = FLY_LAYER //conveniently named

	dir = direction ? EAST : WEST

	var/vertical_ease = pick(EASE_IN|BACK_EASING, QUAD_EASING|EASE_OUT)
	var/vertical_dist = 20 * world.icon_size
	var/vertical_time = round(Frand(1.5 SECONDS, 4 SECONDS), 0.1)

	animate(src, pixel_x = horizontal_dist * direction, time = horizontal_time, easing = EASE_OUT|QUAD_EASING)
	animate(src, pixel_y = vertical_dist, time = vertical_time, easing = vertical_ease, flags = ANIMATION_PARALLEL)
	animate(src, delay = vertical_time - (1 SECOND), alpha = 0, time = round(Frand(1 SECOND, 3 SECONDS)), flags = ANIMATION_PARALLEL)

/datum/proximity_monitor/advanced/crow
	edge_is_a_field = TRUE

	var/datum/sound_token/token

/datum/proximity_monitor/advanced/crow/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(istype(movable, /mob/living/simple_animal/crow))
		return

	if(prob(100 / get_dist(host, movable)) && (movable in viewers(5, host)))
		astype(host, /mob/living/simple_animal/crow).fly_away()
