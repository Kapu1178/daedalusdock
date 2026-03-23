/obj/effect/fakemob
	name = ""
	density = TRUE

	var/mob/living/real_mob

	var/stare_at_mobs = TRUE
	var/mob/living/carbon/human/stare_target

	/// Things to say in sequence
	var/list/dialogue
	/// Current index of the dialogue array.
	var/dialogue_index = 1
	/// Time between speaking.
	COOLDOWN_DECLARE(dialogue_cd)
	/// If this timer passes, set the dialogue index back to 1.
	COOLDOWN_DECLARE(dialogue_reset)

	var/scramble_dialogue_on_reset = FALSE

/obj/effect/fakemob/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/human/dummy/H = create_meat_puppet()
	H.status_flags |= GODMODE
	H.notransform = TRUE
	ADD_TRAIT(H, TRAIT_ACTOR, INNATE_TRAIT)
	real_mob = H

	skinwalk(H)

	START_PROCESSING(SSobj, src)

/obj/effect/fakemob/Destroy(force)
	QDEL_NULL(real_mob)
	STOP_PROCESSING(SSobj, src)
	unset_stare_target()
	return ..()

/obj/effect/fakemob/examine(mob/user)
	return real_mob.examine(user)

/obj/effect/fakemob/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	handle_dialogue(user)

/obj/effect/fakemob/process(delta_time)
	if(stare_at_mobs && !is_interesting(stare_target))
		unset_stare_target()

		var/nearest_mob
		var/nearest_dist = INFINITY
		for(var/mob/living/carbon/human/H in oview(loc))
			if(!is_interesting(H))
				continue

			var/dist = get_dist_euclidean(src, H)
			if(dist > nearest_dist)
				continue

			if(dist < nearest_dist || prob(50))
				nearest_mob = H
				nearest_dist = dist

		if(nearest_mob)
			set_stare_target(nearest_mob)

/// Create the meat puppet the fakemob puppeteers.
/obj/effect/fakemob/proc/create_meat_puppet() as /mob/living/carbon/human/dummy/consistent
	return new /mob/living/carbon/human/dummy/consistent(src)

/obj/effect/fakemob/proc/skinwalk(mob/living/puppet)
	var/original_name = name
	appearance = puppet.appearance
	if(original_name)
		name = original_name
		puppet.set_real_name(original_name)

	real_mob = puppet

/obj/effect/fakemob/proc/set_stare_target(mob/target)
	if(!stare_at_mobs)
		return

	if(stare_target)
		unset_stare_target()

	stare_target = target
	RegisterSignal(stare_target, COMSIG_MOVABLE_MOVED, PROC_REF(stare_target_moved))
	setDir(get_dir(loc, stare_target))

/obj/effect/fakemob/proc/unset_stare_target()
	if(!stare_target)
		return

	stare_target = null
	UnregisterSignal(stare_target, COMSIG_MOVABLE_MOVED)

/obj/effect/fakemob/proc/is_interesting(mob/living/carbon/human/H)
	if(QDELETED(H))
		return FALSE

	if(!H?.client)
		return FALSE

	if(H.body_position == LYING_DOWN)
		return FALSE

	return TRUE

/obj/effect/fakemob/proc/stare_target_moved()
	SIGNAL_HANDLER

	if(QDELETED(stare_target))
		unset_stare_target()
		return

	if(!(stare_target in view(src)))
		unset_stare_target()
		return

	setDir(get_dir(loc, stare_target))

/obj/effect/fakemob/proc/handle_dialogue(mob/living/user)
	if(!length(dialogue))
		return

	if(!COOLDOWN_FINISHED(src, dialogue_cd))
		return

	if(dialogue_reset != 0 && COOLDOWN_FINISHED(src, dialogue_reset))
		reset_dialogue()
		return

	COOLDOWN_START(src, dialogue_cd, 3 SECONDS)
	COOLDOWN_START(src, dialogue_reset, 20 SECONDS)
	real_mob.say(dialogue[dialogue_index])
	set_stare_target(user)

	if(dialogue_index == length(dialogue))
		dialogue_finished()
		return

	dialogue_index++
	return TRUE

/obj/effect/fakemob/proc/reset_dialogue()
	dialogue_index = 1
	dialogue_reset = 0
	COOLDOWN_RESET(src, dialogue_cd)

	if(scramble_dialogue_on_reset)
		shuffle_inplace(dialogue)

/obj/effect/fakemob/proc/dialogue_finished()
	dialogue_reset = 1

/obj/effect/fakemob/holly
	name = "Holly Tall"

	dialogue = list(
		"I can see anything in this beautiful twilight!",
		"Everything's interesting! Is it you or is it me?",
		"Every saint has a sin."
	)

/obj/effect/fakemob/holly/dialogue_finished()
	..()
	dialogue = list(
		"All the light is low...",
		"Where did the time all go?"
	)

/obj/effect/fakemob/holly/create_meat_puppet()
	var/mob/living/carbon/human/dummy/consistent/puppet = ..()
	puppet.set_haircolor("#1e140a")
	puppet.hairstyle = "Diagonal Bangs"
	puppet.gender = FEMALE
	puppet.physique = FEMALE
	puppet.update_body_parts(TRUE)
	puppet.dress_up_as_job(SSjob.GetJob(JOB_ASSISTANT), TRUE)
	return puppet

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

/obj/effect/fakemob/king/Initialize(mapload)
	. = ..()
	real_mob.name = name
	shuffle_inplace(dialogue)

	var/image/I = image('icons/effects/light_overlays/light_96.dmi', "cone")
	I.plane = O_LIGHTING_VISUAL_PLANE
	I.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	I.pixel_x -= 32
	I.pixel_y -= 32
	add_overlay(I)

/obj/effect/fakemob/king/skinwalk(mob/living/puppet)
	return

/obj/effect/fakemob/king/handle_dialogue(mob/living/user)
	. = ..()
	if(!.)
		return

	dialogues_said++
	if(dialogues_said == 4)
		dialogue = list("It is time for you to leave. I cannot go with you.")

/obj/effect/landmark/king
	icon = 'goon/icons/obj/kinginyellow.dmi'
	icon_state = "kingyellow"

/obj/effect/fakemob/roadman
	name = "Constance"

	dialogue = list(
		"This path hasn't gone anywhere for a long time.",
		"Maybe things would be different if it did.",
	)

/obj/effect/fakemob/roadman/create_meat_puppet()
	var/mob/living/carbon/human/dummy/consistent/puppet = ..()
	puppet.set_haircolor("#5e5d5c")
	puppet.hairstyle = "Beachwave"
	puppet.gender = FEMALE
	puppet.physique = FEMALE
	puppet.update_body_parts(TRUE)
	puppet.dress_up_as_job(SSjob.GetJob(JOB_ASSISTANT), TRUE)
	return puppet

/obj/effect/fakemob/stairman
	name = "Clybe"
	dialogue = list(
		"Is my tower not wonderous?",
		"I wish I could keep going higher.",
		"How am I to get down, whence I am so close to heaven?",
	)

/obj/effect/fakemob/stairman/create_meat_puppet()
	var/mob/living/carbon/human/dummy/consistent/puppet = ..()
	puppet.update_body_parts(TRUE)
	puppet.dress_up_as_job(SSjob.GetJob(JOB_STATION_ENGINEER), TRUE)
	return puppet

/obj/effect/mapping_helpers/dead_stairman
	name = "Dead Stairman"

/obj/effect/mapping_helpers/dead_stairman/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/human/consistent/H = new(loc)
	H.dress_up_as_job(SSjob.GetJob(JOB_STATION_ENGINEER), TRUE)
	H.set_real_name("Unknown")
	H.gib(TRUE, TRUE)

/obj/effect/fakemob/mistwalker
	name = "Outsider"

	scramble_dialogue_on_reset = TRUE
	dialogue = list(
		"It's cold outside.",
		"What do you look like?",
		"Isnt it lovely here?",
		"Smile because it happened.",
	)

/obj/effect/fakemob/mistwalker/create_meat_puppet()
	var/mob/living/carbon/human/dummy/consistent/puppet = ..()
	puppet.update_body_parts(TRUE)
	puppet.dress_up_as_job(SSjob.GetJob(JOB_ACOLYTE), TRUE)
	return puppet
