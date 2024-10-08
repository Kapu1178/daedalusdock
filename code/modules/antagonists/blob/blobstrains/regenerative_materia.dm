//does toxin damage, hallucination, targets think they're not hurt at all
/datum/blobstrain/reagent/regenerative_materia
	name = "Regenerative Materia"
	description = "will do medium initial toxin damage, injecting a poison which does more toxin damage and makes targets believe they are fully healed. The core regenerates much faster."
	analyzerdescdamage = "Does medium initial toxin damage, injecting a poison which does more toxin damage and makes targets believe they are fully healed. Core regenerates much faster."
	color = "#A88FB7"
	complementary_color = "#AF7B8D"
	message_living = ", and you feel <i>alive</i>"
	reagent = /datum/reagent/blob/regenerative_materia
	core_regen_bonus = 18
	point_rate_bonus = 1

/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	taste_description = "heaven"
	color = "#A88FB7"

/datum/reagent/blob/regenerative_materia/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.adjust_timed_status_effect(reac_volume * 2 SECONDS, /datum/status_effect/drugginess)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/regenerative_materia, 0.2*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/toxin/spore, 0.2*reac_volume)
	exposed_mob.apply_damage(0.7*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/affect_blood(mob/living/carbon/C, removed)
	. = ..()
	C.adjustToxLoss(1 * removed, FALSE, "Regenerative materia")
	C.hal_screwyhud = SCREWYHUD_HEALTHY //fully healed, honest
	return TRUE

/datum/reagent/blob/regenerative_materia/on_mob_end_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 0
	..()
