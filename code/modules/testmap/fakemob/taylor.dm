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

	var/giving_item = FALSE
	var/given_item = FALSE

/obj/effect/fakemob/taylor/create_meat_puppet()
	var/mob/living/carbon/human/taylor = ..()
	taylor.equipOutfit(/datum/outfit/memory/taylor)
	return taylor

/obj/effect/fakemob/taylor/
/obj/effect/fakemob/taylor/reset_dialogue()
	. = ..()
	dialogue = shuffle(list(
		"Please leave.",
		"I can't stand to see you.",
		"I'm working on it.",
		"I'm sorry.",
	))

/obj/effect/fakemob/taylor/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(given_item || giving_item)
		return

	if(istype(tool, /obj/item/card/id))
		giving_item = TRUE
		SSnowhere.you_did_something_right()
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

/datum/outfit/memory/taylor
	head = /obj/item/clothing/head/ushanka
	uniform = /obj/item/clothing/under/pants/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/jacket
	undershirt = /datum/sprite_accessory/undershirt/shirt_black
