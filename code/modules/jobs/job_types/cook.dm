/datum/job/cook
	title = JOB_COOK
	description = "Serve food, cook meat, keep the crew fed."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION

	pinpad_key = "starvation"

	total_positions = 2
	spawn_positions = 1
	exp_granted_type = EXP_TYPE_CREW

	var/cooks = 0 //Counts cooks amount
	/// List of areas that are counted as the kitchen for the purposes of CQC. Defaults to just the kitchen. Mapping configs can and should override this.
	var/list/kitchen_areas = list(/area/station/service/kitchen)

	employers = list(
		/datum/employer/none
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/cook,
			SPECIES_TESHARI = /datum/outfit/job/cook,
			SPECIES_VOX = /datum/outfit/job/cook,
		),
		"Chef" = list(
			SPECIES_HUMAN = /datum/outfit/job/cook/chef,
			SPECIES_TESHARI = /datum/outfit/job/cook/chef,
			SPECIES_VOX = /datum/outfit/job/cook/chef,
		),
		"Culinary Artist" = list(
			SPECIES_HUMAN = /datum/outfit/job/cook/chef,
			SPECIES_TESHARI = /datum/outfit/job/cook/chef,
			SPECIES_VOX = /datum/outfit/job/cook/chef,
		),
	)

	liver_traits = list(TRAIT_CULINARY_METABOLISM)

	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/reagent_containers/condiment/saltshaker, /obj/item/kitchen/rollingpin, /obj/item/clothing/head/chefhat)
	rpg_title = "Tavern Chef"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/job/cook/New()
	. = ..()
	var/list/job_changes = SSmapping.config.job_changes

	if(!length(job_changes))
		return

	var/list/cook_changes = job_changes[JOB_COOK]

	if(!length(cook_changes))
		return

	var/list/additional_cqc_areas = cook_changes["additional_cqc_areas"]

	if(!additional_cqc_areas)
		return

	if(!islist(additional_cqc_areas))
		stack_trace("Incorrect CQC area format from mapping configs. Expected /list, got: \[[additional_cqc_areas.type]\]")
		return

	for(var/path_as_text in additional_cqc_areas)
		var/path = text2path(path_as_text)
		if(!ispath(path, /area))
			stack_trace("Invalid path in mapping config for chef CQC: \[[path_as_text]\]")
			continue

		kitchen_areas |= path

	mail_goodies = list(
		/obj/item/storage/box/ingredients/random = 80,
		/obj/item/reagent_containers/cup/bottle/caramel = 20,
		/obj/item/reagent_containers/condiment/flour = 20,
		/obj/item/reagent_containers/condiment/rice = 20,
		/obj/item/reagent_containers/condiment/enzyme = 15,
		/obj/item/reagent_containers/condiment/soymilk = 15,
		/obj/item/knife/kitchen = 4,
		/obj/item/knife/butcher = 2
	)

/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	id_template = /datum/access_template/job/cook
	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/apron/chef
	backpack_contents = list(
		/obj/item/choice_beacon/ingredient = 1,
		/obj/item/sharpener = 1,
	)
	belt = /obj/item/modular_computer/tablet/pda/cook
	ears = /obj/item/radio/headset/headset_srv
	head = /obj/item/clothing/head/chefhat
	mask = /obj/item/clothing/mask/fakemoustache/italian

	skillchips = list(/obj/item/skillchip/job/chef)

/* Commenting this out for now, since it overrides alternate job title outfits
/datum/outfit/job/cook/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/datum/job/cook/J = SSjob.GetJobType(jobtype)
	if(J) // Fix for runtime caused by invalid job being passed
		if(J.cooks>0)//Cooks
			id_template = /datum/access_template/job/cook
			suit = /obj/item/clothing/suit/apron/chef
			head = /obj/item/clothing/head/soft/mime
		if(!visualsOnly)
			J.cooks++

/datum/outfit/job/cook/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/suit/apron/chef
	. += /obj/item/clothing/head/soft/mime*/

/datum/outfit/job/cook/chef
	name = "Chef"
	id_template = /datum/access_template/job/cook/chef
	suit = /obj/item/clothing/suit/toggle/chef
