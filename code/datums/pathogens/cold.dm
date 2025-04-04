/datum/pathogen/cold
	name = "The Cold"
	max_stages = 3
	cure_text = "Rest & Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "XY-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human)
	contraction_chance_modifier = 0.5
	desc = "If left untreated the subject will contract the flu."
	severity = PATHOGEN_SEVERITY_NONTHREAT


/datum/pathogen/cold/on_process(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Your throat feels sore."))
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Mucous runs down the back of your throat."))
			if((affected_mob.body_position == LYING_DOWN && DT_PROB(23, delta_time)) || DT_PROB(0.025, delta_time))  //changed FROM prob(10) until sleeping is fixed // Has sleeping been fixed yet?
				to_chat(affected_mob, span_notice("You feel better."))
				force_cure()
				return FALSE
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(0.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Your throat feels sore."))
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("Mucous runs down the back of your throat."))
			if(DT_PROB(0.25, delta_time) && !LAZYFIND(affected_mob.disease_resistances, /datum/pathogen/flu))
				var/datum/pathogen/Flu = new /datum/pathogen/flu()
				affected_mob.try_contract_pathogen(Flu, FALSE, TRUE)
				force_cure()
				return FALSE
			if((affected_mob.body_position == LYING_DOWN && DT_PROB(12.5, delta_time)) || DT_PROB(0.005, delta_time))  //changed FROM prob(5) until sleeping is fixed
				to_chat(affected_mob, span_notice("You feel better."))
				force_cure()
				return FALSE
