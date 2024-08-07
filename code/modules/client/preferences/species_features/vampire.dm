/datum/preference/choiced/vampire_status
	savefile_key = "feature_vampire_status"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS //this will be overwritten by names otherwise
	relevant_species_trait = BLOOD_CLANS

/datum/preference/choiced/vampire_status/create_default_value()
	return "Inoculated" //eh, have em try out the mechanic first

/datum/preference/choiced/vampire_status/init_possible_values()
	var/list/values = list()

	values += "Inoculated"
	values += "Outcast"

	return values

///list that stores a vampire house name for each department
GLOBAL_LIST_EMPTY(vampire_houses)

/datum/preference/choiced/vampire_status/apply_to_human(mob/living/carbon/human/target, value)
	if (!(relevant_species_trait in target.dna?.species.species_traits))
		return

	if(value != "Inoculated")
		return

	//find and setup the house (department) this vampire is joining
	var/datum/job_department/vampire_house
	var/datum/job/vampire_job = SSjob.GetJob(target.job)
	if(!vampire_job) //no job or no mind LOSERS
		return
	var/list/valid_departments = (SSjob.departments.Copy()) - list(/datum/job_department/silicon, /datum/job_department/undefined, /datum/job_department/company_leader)
	for(var/datum/job_department/potential_house as anything in valid_departments)
		if(vampire_job in potential_house.department_jobs)
			vampire_house = potential_house
			break

	if(!vampire_house) //sillycones
		return
	if(!GLOB.vampire_houses[vampire_house.department_name])
		GLOB.vampire_houses[vampire_house.department_name] = pick(GLOB.vampire_house_names)
	var/house_name = GLOB.vampire_houses[vampire_house.department_name]

	//modify name (Platos Syrup > Platos de Lioncourt)
	var/first_space_index = findtextEx(target.real_name, " ")
	var/new_name = copytext(target.real_name, 1, first_space_index + 1)
	new_name += house_name
	target.fully_replace_character_name(target.real_name, new_name)
