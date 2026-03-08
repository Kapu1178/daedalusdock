/obj/effect/fakemob
	name = ""
	density = TRUE

	var/mob/living/real_mob
	var/mob/living/carbon/human/stare_target

	/// Things to say in sequence
	var/list/dialogue
	/// Current index of the dialogue array.
	var/dialogue_index = 1
	/// Time between speaking.
	COOLDOWN_DECLARE(dialogue_cd)
	/// If this timer passes, set the dialogue index back to 1.
	COOLDOWN_DECLARE(dialogue_reset)

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
	if(!is_interesting(stare_target))
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
			stare_target = nearest_mob
			RegisterSignal(stare_target, COMSIG_MOVABLE_MOVED, PROC_REF(stare_target_moved))
			setDir(get_dir(loc, stare_target))

/// Create the meat puppet the fakemob puppeteers.
/obj/effect/fakemob/proc/create_meat_puppet() as /mob/living/carbon/human/dummy/consistent
	return new /mob/living/carbon/human/dummy/consistent(src)

/obj/effect/fakemob/proc/skinwalk(mob/living/puppet)
	var/original_name = name
	appearance = puppet.appearance
	if(original_name)
		name = original_name
		puppet.name = original_name

	real_mob = puppet

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

	if(dialogue_index == length(dialogue))
		dialogue_finished()
		return

	dialogue_index++

/obj/effect/fakemob/proc/reset_dialogue()
	dialogue_index = 1
	dialogue_reset = 0
	COOLDOWN_RESET(src, dialogue_cd)

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

	dialogue = list(
		"All things must come.",
		"Why must I suffer in silence?",
		"This is my pained creation.",
		"It's all coming to a close now."
	)

/obj/effect/fakemob/king/Initialize(mapload)
	. = ..()
	real_mob.name = name

/obj/effect/fakemob/king/skinwalk(mob/living/puppet)
	return

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
