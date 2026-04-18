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

/obj/item/disk/data/floppy/document/code
	title = "ext"
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

/obj/item/disk/data/floppy/document/code/init_file()
	. = ..()
	RegisterSignal(., COMSIG_COMPUTER4_FILE_REMOVED, PROC_REF(on_memory_delete))

/obj/item/disk/data/floppy/document/code/proc/on_memory_delete()
	SIGNAL_HANDLER

	SSnowhere.code_deleted = TRUE
	SSnowhere.check_book()
	SSnowhere.you_did_something_right()

// November

/obj/item/storage/box/old_invite

/obj/item/storage/box/old_invite/PopulateContents()
	new /obj/item/clothing/head/collectable/pirate(src)
	new /obj/item/disk/data/floppy/document/invite(src)
	new /obj/item/toy/plush/moth(src)
