/*Narcolepsy
 * Slight reduction to stealth
 * Reduces resistance
 * Greatly reduces stage speed
 * No change to transmissibility
 * Fatal level
 * Bonus: Causes drowsiness and sleep.
*/
/datum/symptom/narcolepsy
	name = "Narcolepsy"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = 0
	level = 6
	symptom_delay_min = 30
	symptom_delay_max = 85
	severity = 4
	var/yawning = FALSE
	threshold_descs = list(
		"Transmission 4" = "Causes the host to periodically emit a yawn that spreads the virus in a manner similar to that of a sneeze.",
		"Stage Speed 10" = "Causes narcolepsy more often, increasing the chance of the host falling asleep.",
	)

/datum/symptom/narcolepsy/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 4) //yawning (mostly just some copy+pasted code from sneezing, with a few tweaks)
		yawning = TRUE
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 10) //act more often
		symptom_delay_min = 20
		symptom_delay_max = 45

/datum/symptom/narcolepsy/on_process(datum/pathogen/advance/A)
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(50))
				to_chat(M, span_warning("You feel tired."))
		if(2)
			if(prob(50))
				to_chat(M, span_warning("You feel very tired."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("You try to focus on staying awake."))
			if(M.drowsyness < 70)
				M.adjust_drowsyness(5)
		if(4)
			if(prob(50))
				if(yawning)
					to_chat(M, span_warning("You try and fail to suppress a yawn."))
				else
					to_chat(M, span_warning("You nod off for a moment.")) //you can't really yawn while nodding off, can you?
			if(M.drowsyness < 70)
				M.adjust_drowsyness(10)
			if(yawning)
				M.emote("yawn")
				A.airborne_spread(6)
		if(5)
			if(prob(50))
				to_chat(M, span_warning("[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]"))
			if(M.drowsyness < 70)
				M.adjust_drowsyness(40)
			if(yawning)
				M.emote("yawn")
				A.airborne_spread(6)
