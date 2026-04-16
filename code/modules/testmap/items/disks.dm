/obj/item/disk/data/floppy/document/invite
	file_name = "come_visit_copy"

	file_fields = list(
		"To: Taylor J",
		"From: Jacqueline J",
		"",
		"Taylor, it's so wonderful here, you know you can always come visit!",
		"We really miss you, it's been years since we last saw the real you.",
		"Summer is coming up, and we're right on the lake, you could go swimming!",
	)

// November

/obj/item/storage/box/old_invite

/obj/item/storage/box/old_invite/PopulateContents()
	new /obj/item/clothing/head/collectable/pirate(src)
	new /obj/item/disk/data/floppy/document/invite(src)
	new /obj/item/toy/plush/moth(src)
