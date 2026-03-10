/obj/item/disk/data/floppy/document
	name = "old floppy disk"

	var/file_name = "note"
	var/list/file_fields

/obj/item/disk/data/floppy/document/Initialize(mapload)
	. = ..()
	if(!length(file_fields))
		stack_trace("Document floppy with no text at [AREACOORD(src)], please fix.")
		return INITIALIZE_HINT_QDEL

	var/datum/c4_file/record/file = new
	file.set_name(file_name)
	file.stored_record.fields = file_fields
	root.try_add_file(file)

	file_fields = null // Don't keep a ref to the file fields, we don't need them anyway, so don't copy and waste memory.

/obj/item/disk/data/floppy/document/invite
	name = "come_visit_copy"

	file_fields = list(
		"To: Taylor J",
		"From: Jacqueline J",
		"",
		"Taylor, it's so wonderful here, you know you can always come visit!",
		"We really miss you, it's been years since we last saw the real you.",
		"Summer is coming up, and we're right on the lake, you could go swimming!",
	)

// November
