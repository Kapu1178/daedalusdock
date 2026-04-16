/obj/machinery/computer4/testmap
	default_peripherals = list(/obj/item/peripheral/card_reader, /obj/item/peripheral/printer)

/obj/machinery/computer4/testmap/Initialize(mapload)
	. = ..()
	var/datum/c4_file/record/file = new
	file.set_name("memory")
	file.extension = "DM"
	file.stored_record.fields = list(
		"/datum/outfit/memory",
		"	name = /datum/job/memory::title",
		"",
		"	uniform = /obj/item/clothing/under/costume/actor",
		"	shoes = /obj/item/clothing/shoes/actor",
		"",
		"	back = /obj/item/storage/backpack/actor",
		"	backpack_contents = list(/obj/item/flashlight/seclite/actor)",
	)
	internal_disk.root.try_add_file(file)
