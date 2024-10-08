#define GORILLA_MUTATION_CHANCE_PER_SECOND 0.25
#define GORILLA_MUTATION_MINIMUM_DAMAGE 2500

/// Genetic damage, given by DNA consoles, will start to deal toxin damage
/// past a certain threshold, and will go down consistently.
/// Adding multiple of this component will increase the total damage.
/// Can turn monkeys into gorillas.
/datum/component/genetic_damage
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The total genetic damage on the mob
	var/total_damage = 0

	/// The amount of genetic damage a mob can sustain before taking damage
	var/minimum_before_damage = 500

	/// The amount of genetic damage to remove per second
	var/remove_per_second = 1 / 3

	/// The amount of toxin damage to deal per second, if over the minimum before taking damage
	var/toxin_damage_per_second = 1 / 3

/datum/component/genetic_damage/Initialize(genetic_damage)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.total_damage = genetic_damage

	START_PROCESSING(SSprocessing, src)

/datum/component/genetic_damage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))

/datum/component/genetic_damage/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_HEALTHSCAN)

/datum/component/genetic_damage/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)

	return ..()

/datum/component/genetic_damage/InheritComponent(datum/component/genetic_damage/old_component)
	total_damage += old_component.total_damage

/datum/component/genetic_damage/process(delta_time)
	if (ismonkey(parent) && total_damage >= GORILLA_MUTATION_MINIMUM_DAMAGE && DT_PROB(GORILLA_MUTATION_CHANCE_PER_SECOND, delta_time))
		var/mob/living/carbon/carbon_parent = parent
		carbon_parent.gorillize()
		qdel(src)
		return PROCESS_KILL

	if (total_damage >= minimum_before_damage)
		var/mob/living/living_mob = parent
		living_mob.adjustToxLoss(toxin_damage_per_second * delta_time, cause_of_death = "Genetic breakdown")

	total_damage -= remove_per_second * delta_time
	if (total_damage <= 0)
		qdel(src)
		return PROCESS_KILL

/datum/component/genetic_damage/proc/on_healthscan(datum/source, list/render_string, mob/user, mode, advanced)
	SIGNAL_HANDLER

	if (advanced)
		render_string += "<span style='font-weight: bold; color: [COLOR_MEDICAL_GENETIC]'>Genetic damage: [round(total_damage / minimum_before_damage * 100, 0.1)]%</span>\n"

#undef GORILLA_MUTATION_CHANCE_PER_SECOND
#undef GORILLA_MUTATION_MINIMUM_DAMAGE
