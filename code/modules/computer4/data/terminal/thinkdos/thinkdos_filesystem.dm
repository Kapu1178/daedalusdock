/datum/c4_file/terminal_program/operating_system/thinkdos/proc/new_file(file_type, owner, group, permissions)
	RETURN_TYPE(/datum/c4_file)
	var/datum/c4_file/file = new file_type
	file.metadata.permission = permissions || ALL
	file.metadata.owner = owner || THINKDOS_ADMIN_ACC_NAME
	file.metadata.group = group || THINKDOS_ADMIN_GROUP
	return file

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/os_write_file(datum/c4_file/file, datum/c4_file/folder/directory, datum/c4_file/user/user)
	. = "Uncaught exception occurred."

	if(!check_perms_write(directory, user))
		return "Access denied."

	if(!directory.try_add_file(file))
		return "Cannot write to directory."

	return 0

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/os_delete_file(datum/c4_file/file, datum/c4_file/user/user)
	. = "Uncaught exception occurred."

	if(!check_perms_write(file.containing_folder))
		return "Access denied."

	if(!file.containing_folder.try_delete_file(file))
		return "Unable to delete file."

	return 0

/// Check if the given user can access the given file.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/check_perms_read(datum/c4_file/file, datum/c4_file/user/user)
	if(!user)
		user = current_user
		if(!user)
			return FALSE

	if(!file)
		return FALSE

	if(!file.metadata)
		return TRUE

	var/file_perms = file.metadata.permission

	// File is public use.
	if(file_perms & PERM_READ_PUBLIC)
		return TRUE

	// User is the owner of the file and the file allows owner reads.
	if((file_perms & PERM_READ_OWNER) && (user.registered_name == file.metadata.owner))
		return TRUE

	// User is apart of the group that owns the file and the file allows group reads.
	if(file.metadata.group && (file_perms & PERM_READ_GROUP) && (file.metadata.group in user.permission_groups))
		return TRUE

	return FALSE

/// Check if the given user can write to the given file.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/check_perms_write(datum/c4_file/file, datum/c4_file/user/user)
	if(!user)
		user = current_user
		if(!user)
			return FALSE

	if(!file)
		return FALSE

	if(!file.metadata)
		return TRUE

	var/file_perms = file.metadata.permission

	// File is public use.
	if(file_perms & PERM_WRITE_PUBLIC)
		return TRUE

	// User is the owner of the file and the file allows owner reads.
	if((file_perms & PERM_WRITE_OWNER) && (user.registered_name == file.metadata.owner))
		return TRUE

	// User is apart of the group that owns the file and the file allows group reads.
	if(file.metadata.group && (file_perms & PERM_WRITE_GROUP) && (file.metadata.group in user.permission_groups))
		return TRUE

	return FALSE

/// Check if the given user can execute the given file.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/check_perms_execute(datum/c4_file/file, datum/c4_file/user/user)
	if(!user)
		user = current_user
		if(!user)
			return FALSE

	if(!file)
		return FALSE

	if(!file.metadata)
		return TRUE

	var/file_perms = file.metadata.permission

	// File is public use.
	if(file_perms & PERM_EXECUTE_PUBLIC)
		return TRUE

	// User is the owner of the file and the file allows owner reads.
	if((file_perms & PERM_EXECUTE_OWNER) && (user.registered_name == file.metadata.owner))
		return TRUE

	// User is apart of the group that owns the file and the file allows group reads.
	if(file.metadata.group && (file_perms & PERM_EXECUTE_GROUP) && (file.metadata.group in user.permission_groups))
		return TRUE

	return FALSE
