/datum/job/bartender
	title = JOB_BARTENDER
	description = "Serve booze, mix drinks, keep the crew drunk."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	pinpad_key = "ILOVESERVINGALCOHOLTODRUNKPEOPLE"

	total_positions = 1
	spawn_positions = 1
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/none
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/bartender,
		),
	)

	departments_list = list(
		/datum/job_department/service,
	)

	family_heirlooms = list(/obj/item/reagent_containers/cup/rag, /obj/item/clothing/head/that, /obj/item/reagent_containers/cup/glass/shaker)

	mail_goodies = list(
		/obj/item/storage/box/rubbershot = 30,
		/obj/item/reagent_containers/cup/bottle/clownstears = 10,
		/obj/item/stack/sheet/mineral/plasma = 10,
		/obj/item/stack/sheet/mineral/uranium = 10,
	)

	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN
	rpg_title = "Tavernkeeper"

/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender

	id_template = /datum/access_template/job/bartender
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	backpack_contents = list(
		/obj/item/storage/box/beanbag = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/bar
	ears = /obj/item/radio/headset/headset_srv
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/job/bartender/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	var/obj/item/card/id/W = H.wear_id.GetID(TRUE)
	if(H.age < AGE_MINOR)
		W.registered_age = AGE_MINOR
		to_chat(H, span_notice("You're not technically old enough to access or serve alcohol, but your ID has been discreetly modified to display your age as [AGE_MINOR]. Try to keep that a secret!"))
