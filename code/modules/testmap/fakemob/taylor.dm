/obj/effect/fakemob/taylor
	name = "Taylor"

	stare_at_mobs = FALSE

	dialogue = list(
		"%All hail the manatee, heads up she's passing by!",
		"Maybe things would be different if it did.",
		"98 parse let's fucking go.",
		"Have you heard of the hit game Pathologic?",
		"You should read Sacred and Terrible Air.",
		"FUCK MY CHUD LIFE!",
		"This Invoker is a fucking brainlet duuuuuude.",
		"I think we should kill this guy."
	)

/obj/effect/fakemob/taylor/create_meat_puppet()
	var/mob/living/carbon/human/taylor = ..()
	taylor.equipOutfit(/datum/outfit/memory/taylor)
	return taylor

/obj/effect/fakemob/taylor/reset_dialogue()
	. = ..()
	dialogue = shuffle(list(
		"Please leave.",
		"I can't stand to see you.",
		"I'm working on it.",
		"I'm sorry.",
	))

/obj/effect/fakemob/taylor/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/card/id))
		COOLDOWN_START(src, dialogue_cd, 10 SECONDS)
		reset_dialogue()
		spawn(-1)
			face_atom(user)
			sleep(1 SECONDS)
			real_mob.say("Please, get rid of this. I don't want it anymore.")
			sleep(1 SECONDS)
			var/obj/item/disk/data/floppy/document/code/disk = new
			if(!user.put_in_hands(disk))
				disk.forceMove(get_turf(src))
			sleep(2 SECONDS)
			setDir(SOUTH)
		return ITEM_INTERACT_SUCCESS

/obj/item/disk/data/floppy/document/code
	file_name = "memory"
	file_extension = "DM"
	file_fields = list(
		"/datum/outfit/memory",
		"	name = /datum/job/memory::title",
		"",
		"	uniform = /obj/item/clothing/under/costume/actor",
		"	shoes = /obj/item/clothing/shoes/actor",
		"",
		"	back = /obj/item/storage/backpack/actor",
		"	backpack_contents = list(/obj/item/flashlight/seclite/actor)",
	)


/datum/outfit/memory/taylor
	head = /obj/item/clothing/head/ushanka
	uniform = /obj/item/clothing/under/pants/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/jacket
	undershirt = /datum/sprite_accessory/undershirt/shirt_black
