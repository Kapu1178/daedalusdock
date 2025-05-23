/**Spontaneous Combustion
 * Slightly hidden.
 * Lowers resistance tremendously.
 * Decreases stage speed tremendously.
 * Decreases transmittablity tremendously.
 * Fatal level
 * Bonus: Ignites infected mob.
 */

/datum/symptom/fire
	name = "Spontaneous Combustion"
	desc = "The virus turns fat into an extremely flammable compound, and raises the body's temperature, making the host burst into flames spontaneously."
	stealth = -1
	resistance = -4
	stage_speed = -3
	transmittable = -4
	level = 6
	severity = 5
	base_message_chance = 20
	symptom_delay_min = 20
	symptom_delay_max = 75
	var/infective = FALSE
	threshold_descs = list(
		"Stage Speed 4" = "Increases the intensity of the flames.",
		"Stage Speed 8" = "Further increases flame intensity.",
		"Transmission 8" = "Host will spread the virus through skin flakes when bursting into flame.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)

/datum/symptom/fire/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 4)
		power = 1.5
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 8)
		power = 2
	if(properties[PATHOGEN_PROP_STEALTH] >= 4)
		suppress_warning = TRUE
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 8) //burning skin spreads the virus through smoke
		infective = TRUE

/datum/symptom/fire/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, span_warning("[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]"))
		if(4)
			Firestacks_stage_4(M, A)
			M.ignite_mob()
			to_chat(M, span_userdanger("Your skin bursts into flames!"))
			M.emote("scream")
		if(5)
			Firestacks_stage_5(M, A)
			M.ignite_mob()
			to_chat(M, span_userdanger("Your skin erupts into an inferno!"))
			M.emote("scream")

/datum/symptom/fire/proc/Firestacks_stage_4(mob/living/M, datum/pathogen/advance/A)
	M.adjust_fire_stacks(1 * power)
	M.take_overall_damage(burn = 3 * power, required_status = BODYTYPE_ORGANIC)
	if(infective)
		A.airborne_spread(2, FALSE)
	return 1

/datum/symptom/fire/proc/Firestacks_stage_5(mob/living/M, datum/pathogen/advance/A)
	M.adjust_fire_stacks(3 * power)
	M.take_overall_damage(burn = 5 * power, required_status = BODYTYPE_ORGANIC)
	if(infective)
		A.airborne_spread(4, FALSE)
	return 1

/*
Alkali perspiration
	Hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmissibility.
	Fatal Level.
Bonus
	Ignites infected mob.
	Explodes mob on contact with water.
*/

/datum/symptom/alkali

	name = "Alkali perspiration"
	desc = "The virus attaches to sudoriparous glands, synthesizing a chemical that bursts into flames when reacting with water, leading to self-immolation."
	stealth = 2
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 7
	severity = 6
	base_message_chance = 100
	symptom_delay_min = 30
	symptom_delay_max = 90
	var/chems = FALSE
	var/explosion_power = 1
	threshold_descs = list(
		"Resistance 9" = "Doubles the intensity of the immolation effect, but reduces the frequency of all of this symptom's effects.",
		"Stage Speed 8" = "Increases explosion radius and explosion damage to the host when the host is wet.",
		"Transmission 8" = "Additionally synthesizes chlorine trifluoride and napalm inside the host. More chemicals are synthesized if the resistance 9 threshold has been met."
	)

/datum/symptom/alkali/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 9) //intense but sporadic effect
		power = 2
		symptom_delay_min = 50
		symptom_delay_max = 140
	if(properties[PATHOGEN_PROP_STAGE_RATE] >= 8) //serious boom when wet
		explosion_power = 2
	if(properties[PATHOGEN_PROP_TRANSMITTABLE] >= 8) //extra chemicals
		chems = TRUE

/datum/symptom/alkali/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance))
				to_chat(M, span_warning("[pick("Your veins boil.", "You feel hot.", "You smell meat cooking.")]"))
		if(4)
			if(M.fire_stacks < 0)
				M.visible_message(span_warning("[M]'s sweat sizzles and pops on contact with water!"))
				explosion(M, devastation_range = -1, heavy_impact_range = (-1 + explosion_power), light_impact_range = (2 * explosion_power), explosion_cause = src)
			Alkali_fire_stage_4(M, A)
			M.ignite_mob()
			to_chat(M, span_userdanger("Your sweat bursts into flames!"))
			M.emote("scream")
		if(5)
			if(M.fire_stacks < 0)
				M.visible_message(span_warning("[M]'s sweat sizzles and pops on contact with water!"))
				explosion(M, devastation_range = -1, heavy_impact_range = (-1 + explosion_power), light_impact_range = (2 * explosion_power), explosion_cause = src)
			Alkali_fire_stage_5(M, A)
			M.ignite_mob()
			to_chat(M, span_userdanger("Your skin erupts into an inferno!"))
			M.emote("scream")

/datum/symptom/alkali/proc/Alkali_fire_stage_4(mob/living/M, datum/pathogen/advance/A)
	var/get_stacks = 6 * power
	M.adjust_fire_stacks(get_stacks)
	M.take_overall_damage(burn = get_stacks / 2, required_status = BODYTYPE_ORGANIC)
	if(chems)
		M.reagents.add_reagent(/datum/reagent/clf3, 2 * power)
	return 1

/datum/symptom/alkali/proc/Alkali_fire_stage_5(mob/living/M, datum/pathogen/advance/A)
	var/get_stacks = 8 * power
	M.adjust_fire_stacks(get_stacks)
	M.take_overall_damage(burn = get_stacks, required_status = BODYTYPE_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list(/datum/reagent/napalm = 4 * power, /datum/reagent/clf3 = 4 * power))
	return 1
