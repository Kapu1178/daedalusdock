/obj/item/disk/data/floppy/document
	name = "old floppy disk"

	var/file_name = "note"
	var/file_extension = "REC"
	var/list/file_fields

/obj/item/disk/data/floppy/document/Initialize(mapload)
	. = ..()
	if(!length(file_fields))
		stack_trace("Document floppy with no text at [AREACOORD(src)], please fix.")
		return INITIALIZE_HINT_QDEL

	var/datum/c4_file/record/file = new
	file.set_name(file_name)
	file.extension = file_extension
	file.stored_record.fields = file_fields
	root.try_add_file(file)

	file_fields = null // Don't keep a ref to the file fields, we don't need them anyway, so don't copy and waste memory.
