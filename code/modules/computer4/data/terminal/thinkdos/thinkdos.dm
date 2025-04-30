/datum/c4_file/terminal_program/operating_system/thinkdos
	name = "ThinkDOS"

	var/system_version = "ThinkDOS 0.7.2"

	/// Shell commmands for std_in, built on new.
	var/static/list/commands

	/// Boolean, determines if errors are written to the log file.
	var/log_errors = TRUE

	/// Current logged in user, if any.
	var/datum/c4_file/user/current_user

	/// The command log.
	var/datum/c4_file/text/command_log

	/// Required access (ALL) on the ID card to log into the admin account.
	var/list/access_for_admin = list()

/datum/c4_file/terminal_program/operating_system/thinkdos/New()
	..()
	metadata.owner = THINKDOS_OWNER_SYSTEM
	metadata.permission = PERM_WRITE_OWNER | PERM_READ_OWNER // Owner does not have execution perms. Owner cannot kill the operating system process. you will rm -rf and you will like it.
	metadata.group = THINKDOS_ADMIN_GROUP

	if(!commands)
		commands = list()
		for(var/datum/shell_command/thinkdos/command_path as anything in subtypesof(/datum/shell_command/thinkdos))
			commands += new command_path

/datum/c4_file/terminal_program/operating_system/thinkdos/execute()
	containing_folder.metadata.owner = THINKDOS_OWNER_SYSTEM
	containing_folder.metadata.permission = PERM_WRITE_GROUP | PERM_READ_PUBLIC | PERM_EXECUTE_GROUP
	containing_folder.metadata.group = THINKDOS_ADMIN_GROUP

	if(!initialize_logs())
		println("<font color=red>Log system failure.</font>")

	if(!initialize_accounts())
		println("<font color=red>Unable to start account system.</font>")

	change_dir(containing_folder)

	var/gamertext = @{"<pre>
 ___  _    _       _    ___  ___  ___
|_ _|| |_ &lt;_&gt;._ _ | |__| . \| . |/ __&gt;
 | | | . || || &#39; || / /| | || | |\__ \
 |_| |_|_||_||_|_||_\_\|___/`___&#39;&lt;___/</pre>"}
	println(gamertext)

/datum/c4_file/terminal_program/operating_system/thinkdos/std_in(text)
	. = ..()
	if(.)
		return

	var/encoded_in = html_encode(text)
	println(encoded_in)
	write_log(encoded_in)

	var/datum/shell_stdin/parsed_stdin = parse_std_in(text)
	if(!current_user)
		var/datum/shell_command/thinkdos/login/login_command = locate() in commands
		if(!login_command.try_exec(parsed_stdin.command, src, src, parsed_stdin.arguments, parsed_stdin.options))
			println("Login required. Please login using 'login'.")
		return

	for(var/datum/shell_command/potential_command as anything in commands)
		if(potential_command.try_exec(parsed_stdin.command, src, src, parsed_stdin.arguments, parsed_stdin.options))
			return TRUE

	println("'[html_encode(parsed_stdin.raw)]' is not recognized as an internal or external command.")
	return TRUE

/// Write to the command log.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/write_log(text)
	if(!command_log || drive.read_only)
		return FALSE

	command_log.data += text
	return TRUE

/// Write to the command log if it's enabled, then print to the screen.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/print_error(text)
	if(log_errors)
		write_log(text)

	return println(text)

/// Schedule a callback for the system to invoke after the specified time if able.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/schedule_proc(datum/callback/callback, time)
	addtimer(CALLBACK(src, PROC_REF(execute_scheduled_proc)), time)

/// See schedule_proc()
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/execute_scheduled_proc(datum/callback/callback)
	PRIVATE_PROC(TRUE)

	if(!is_operational())
		return

	callback.Invoke()

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/login(account_name, account_occupation, account_access)
	if(!account_name || !account_occupation)
		return FALSE

	if(!initialize_accounts())
		return FALSE

	var/list/user_access = text2access(account_access)
	var/datum/c4_file/user/login_user = get_user_account(user_access)
	if(isnull(login_user))
		return FALSE

	login_user.registered_name = account_name
	login_user.assignment = account_occupation
	login_user.access = user_access
	set_current_user(login_user)

	write_log("<b>LOGIN</b>: [html_encode(account_name)] | [html_encode(account_occupation)]")
	println("Welcome [html_encode(account_name)]!<br><b>Current Directory: [current_directory.path_to_string()]</b>")
	println("You are logged in as \a [current_user.name == THINKDOS_ADMIN_ACC_NAME ? "admin" : "guest"].")
	return TRUE

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/logout()
	if(!current_user)
		print_error("<b>Error:</b> Account system inactive.")
		return FALSE

	write_log("<b>LOGOUT:</b> [html_encode(current_user.registered_name)]")
	set_current_user(null)
	return TRUE

/// Returns the logging folder, attempting to create it if it doesn't already exist.
/datum/c4_file/terminal_program/operating_system/thinkdos/get_log_folder()
	var/datum/c4_file/folder/log_dir = parse_directory("logs", drive.root)
	if(!log_dir)
		log_dir = new_file(
			/datum/c4_file/folder,
			THINKDOS_OWNER_SYSTEM,
			THINKDOS_ADMIN_GROUP,
			PERM_WRITE_GROUP | PERM_READ_PUBLIC
		)
		log_dir.set_name("logs")
		if(!drive.root.try_add_file(log_dir))
			qdel(log_dir)
			return null

	return log_dir

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/get_user_folder()
	RETURN_TYPE(/datum/c4_file/folder)

	var/datum/c4_file/folder/account_dir = parse_directory("users")
	if(istype(account_dir))
		return account_dir

	if(account_dir && !account_dir.containing_folder.try_delete_file(account_dir))
		print_error("<b>Error:</b> Unable to write account folder.")
		return FALSE

	account_dir = new_file(
		/datum/c4_file/folder,
		THINKDOS_OWNER_SYSTEM,
		group = THINKDOS_ADMIN_GROUP,
		permissions = PERM_WRITE_GROUP | PERM_READ_GROUP | PERM_EXECUTE_GROUP,
	)
	account_dir.set_name("users")

	if(!containing_folder.try_add_file(account_dir))
		qdel(account_dir)
		print_error("<b>Error:</b> Unable to write account folder.")
		return FALSE

	RegisterSignal(account_dir, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_COMPUTER4_FILE_REMOVED), PROC_REF(user_folder_gone))
	return account_dir

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/get_user_account(list/access)
	if(length(access & access_for_admin) == length(access_for_admin))
		return assert_user_account(THINKDOS_ADMIN_ACC_NAME)
	else
		return assert_user_account(THINKDOS_GUEST_ACC_NAME)

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/assert_user_account(file_name)
	RETURN_TYPE(/datum/c4_file/user)

	var/datum/c4_file/folder/users_dir = get_user_folder()
	if(!users_dir)
		return null

	var/datum/c4_file/user/user_data = users_dir.get_file(file_name, FALSE)
	if(istype(user_data))
		return user_data

	if(!isnull(user_data) && !user_data.containing_folder.try_delete_file(user_data))
		print_error("<b>Error:</b> Unable to write account folder.")
		return null

	user_data = new_file(
		/datum/c4_file/user,
		THINKDOS_OWNER_SYSTEM,
		THINKDOS_ADMIN_GROUP,
		PERM_READ_GROUP | PERM_WRITE_GROUP | PERM_EXECUTE_GROUP,
	)

	if(file_name == THINKDOS_ADMIN_ACC_NAME)
		user_data.permission_groups = list(THINKDOS_ADMIN_GROUP)

	if(users_dir.try_add_file(user_data))
		return user_data

	qdel(user_data)
	print_error("<b>Error:</b> Unable to write account file.")

/// Create the log file, or append a startup log.
/datum/c4_file/terminal_program/operating_system/thinkdos/proc/initialize_logs()
	if(command_log)
		return TRUE

	var/datum/c4_file/folder/log_dir = get_log_folder()
	var/datum/c4_file/text/log_file = log_dir.get_file("syslog")
	if(!log_file)
		log_file = new_file(
			/datum/c4_file/text,
			THINKDOS_OWNER_SYSTEM,
			THINKDOS_ADMIN_GROUP,
			PERM_WRITE_GROUP | PERM_READ_PUBLIC,
		)
		log_file.set_name("syslog")
		if(!log_dir.try_add_file(log_file))
			qdel(log_file)
			return FALSE

	command_log = log_file
	RegisterSignal(command_log, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_PARENT_QDELETING), PROC_REF(log_file_gone))

	log_file.data += "<br><b>STARTUP:</b> [stationtime2text()], [stationdate2text()]"
	return TRUE

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/initialize_accounts()
	var/datum/c4_file/user/user_data = get_user_account(access_for_admin)
	if(!user_data)
		return FALSE
	return TRUE

/datum/c4_file/terminal_program/operating_system/thinkdos/proc/set_current_user(datum/c4_file/user/new_user)
	if(current_user)
		UnregisterSignal(current_user, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_COMPUTER4_FILE_REMOVED))

	current_user = new_user

	if(current_user)
		RegisterSignal(current_user, list(COMSIG_COMPUTER4_FILE_RENAMED, COMSIG_COMPUTER4_FILE_ADDED, COMSIG_COMPUTER4_FILE_REMOVED), PROC_REF(user_file_gone))
	else
		var/obj/machinery/computer4/computer = get_computer()
		for(var/datum/c4_file/terminal_program/running_program as anything in computer.processing_programs)
			if(running_program == src)
				continue

			computer.unload_program(running_program)

