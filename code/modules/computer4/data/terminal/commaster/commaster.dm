/datum/c4_file/terminal_program/commaster
	name = "comMaster"

	req_access = list(ACCESS_CAPTAIN)

	var/static/list/main_commands

/datum/c4_file/terminal_program/commaster/New()
	..()

	if(!main_commands)
		main_commands = list()
		for(var/path as anything in subtypesof(/datum/shell_command/commaster))
			main_commands += new path

/datum/c4_file/terminal_program/commaster/execute(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/parsed_cmdline/cmdline)
	. = ..()

	var/title_text = list(
		"						 __  ______   _____________________  ","\n",
		"  _________  ____ ___  /  |/  /   | / ___/_  __/ ____/ __ \ ","\n",
		" / ___/ __ \\/ __ `__ \\/ /|_/ / /| | \\__ \ / / / __/ / /_/ / ","\n",
		"/ /__/ /_/ / / / / / / /  / / ___ |___/ // / / /___/ _, _/  ","\n",
		"\\___/\\____/_/ /_/ /_/_/  /_/_/  |_/____//_/ /_____/_/ |_|   ","\n",
	).Join("")

	system.println(title_text)

/datum/c4_file/terminal_program/commaster/std_in(text)
	. = ..()
	var/datum/parsed_cmdline/parsed_cmdline = parse_cmdline(text)

	var/datum/c4_file/terminal_program/operating_system/system = get_os()
	system.println(text)

	for(var/datum/shell_command/potential_command as anything in main_commands)
		if(potential_command.try_exec(parsed_cmdline.command, system, src, parsed_cmdline.arguments, parsed_cmdline.options))
			return TRUE

	system.println("'[parsed_cmdline.raw]' is not recognized as a command.")

// /datum/c4_file/terminal_program/commaster/proc/post_status(command, msg1, msg2)
// 	var/datum/signal/status_signal = new(null, packetv2(payload = list(PKT_ARG_CMD = command)))
// 	switch(command)
// 		if("message")
// 			status_signal.data[PKT_PAYLOAD]["msg1"] = data1
// 			status_signal.data[PKT_PAYLOAD]["msg2"] = data2
// 		if("alert")
// 			status_signal.data[PKT_PAYLOAD]["picture_state"] = data1

// 	get_adapter().post_signal(status_signal)

/// Getter for a network adapter.
/datum/c4_file/terminal_program/commaster/proc/get_adapter() as /obj/item/peripheral/network_card
	return get_computer().get_peripheral(PERIPHERAL_TYPE_WIRELESS_CARD)

/datum/c4_file/terminal_program/commaster/proc/get_netjack() as /obj/machinery/power/data_terminal
	return get_computer().netjack
