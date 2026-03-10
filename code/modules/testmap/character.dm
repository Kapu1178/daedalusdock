/datum/job/character
	title = "Actor"
	job_flags = JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK

	spawn_positions = -1
	total_positions = -1

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/character,
		),
	)

/datum/outfit/character
	name = /datum/job/character::title

	uniform = /obj/item/clothing/under/costume/actor
	shoes = /obj/item/clothing/shoes/actor

	back = /obj/item/storage/backpack/actor
	backpack_contents = list(/obj/item/flashlight/seclite/actor)

/obj/item/clothing/under/costume/actor
	name = "ragged clothes"
	desc = "Birds may believe at a distance."
	icon_state = "scarecrow"
	inhand_icon_state = "scarecrow"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = FLAMMABLE

/obj/item/clothing/shoes/actor
	name = "worn boots"
	desc = "A time-worn pair of field boots."
	icon_state = "explorer"

	resistance_flags = FLAMMABLE

	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/storage/backpack/actor
	name = "old backpack"
	desc = "A fraying backpack, atleast it's still in one piece."
	icon_state = "explorerpack"
	inhand_icon_state = "explorerpack"

/obj/item/flashlight/seclite/actor
	name = "flashlight"
	desc = "A handheld light projector."

	light_color = LIGHTBULB_COLOR_SLIGHTLY_WARM
	light_power = 0.1
	light_outer_range = 1.5

/obj/item/flashlight/lantern/actor
	light_outer_range = 4
