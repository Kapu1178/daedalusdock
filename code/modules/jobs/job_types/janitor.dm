/datum/job/janitor
	title = JOB_JANITOR
	description = "Clean up trash and blood. Replace broken lights. Slip people over."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION

	pinpad_key = "REEEEEEEJANNIESGETOUT"

	total_positions = 2
	spawn_positions = 1

	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/none
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/janitor,
		),
	)

	departments_list = list(
		/datum/job_department/service,
		)

	family_heirlooms = list(/obj/item/mop, /obj/item/clothing/suit/caution, /obj/item/reagent_containers/cup/bucket, /obj/item/paper/fluff/stations/soap)

	mail_goodies = list(
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10
	)
	rpg_title = "Groundskeeper"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	id_template = /datum/access_template/job/janitor
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	belt = /obj/item/modular_computer/tablet/pda/janitor
	ears = /obj/item/radio/headset/headset_srv
	gloves = /obj/item/clothing/gloves/cleaning

/datum/outfit/job/janitor/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(GARBAGEDAY in SSevents.holidays)
		backpack_contents += /obj/item/gun/ballistic/revolver
		r_pocket = /obj/item/ammo_box/a357

/datum/outfit/job/janitor/get_types_to_preload()
	. = ..()
	if(GARBAGEDAY in SSevents.holidays)
		. += /obj/item/gun/ballistic/revolver
		. += /obj/item/ammo_box/a357
