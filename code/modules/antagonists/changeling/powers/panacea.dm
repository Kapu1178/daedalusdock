/datum/action/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing diseases, removing parasites, sobering us, purging toxins and radiation, curing traumas and brain damage, and resetting our genetic code completely. Costs 20 chemicals."
	helptext = "Can be used while unconscious."
	button_icon_state = "panacea"
	chemical_cost = 20
	dna_cost = 1
	req_stat = UNCONSCIOUS

//Heals the things that the other regenerative abilities don't.
/datum/action/changeling/panacea/sting_action(mob/user)
	to_chat(user, span_notice("We cleanse impurities from our form."))
	..()
	var/list/bad_organs = list(
		user.getorgan(/obj/item/organ/body_egg),
		user.getorgan(/obj/item/organ/zombie_infection))

	for(var/o in bad_organs)
		var/obj/item/organ/O = o
		if(!istype(O))
			continue

		O.Remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(0)
		O.forceMove(get_turf(user))

	user.reagents.add_reagent(/datum/reagent/medicine/ryetalyn, 10)
	user.reagents.add_reagent(/datum/reagent/medicine/dexalin, 20)
	user.reagents.add_reagent(/datum/reagent/medicine/antihol, 10)
	user.reagents.add_reagent(/datum/reagent/medicine/alkysine, 25)

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)

	if(isliving(user))
		var/mob/living/L = user
		for(var/thing in L.diseases)
			var/datum/pathogen/D = thing
			if(D.severity == PATHOGEN_SEVERITY_POSITIVE)
				continue
			D.force_cure()
	return TRUE
