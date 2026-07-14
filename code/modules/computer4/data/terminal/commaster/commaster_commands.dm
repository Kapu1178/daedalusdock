/datum/shell_command/commaster/quit
	aliases = list("quit", "q", "exit")

/datum/shell_command/commaster/quit/exec(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/c4_file/terminal_program/program, list/arguments, list/options)
	system.println("Quitting...")
	system.unload_program(program)

/datum/shell_command/commaster/call_shuttle
	aliases = list("call")

/datum/shell_command/commaster/call_shuttle/exec(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/c4_file/terminal_program/program, list/arguments, list/options)
	var/datum/c4_file/terminal_program/commaster/commaster = program
	var/obj/machinery/power/data_terminal/netjack = commaster.get_netjack()

	if(!netjack)
		system.println("[ANSI_WRAP_BOLD("Error:")] Console is not connected to the wirenet.")
		return

	if(!length(arguments))
		system.print_error("[ANSI_WRAP_BOLD("Error:")] Must provide a call reason.")
		return

	var/reason = trim(jointext(arguments, " "))
	if (length(reason) < CALL_SHUTTLE_REASON_LENGTH)
		system.print_error("[ANSI_WRAP_BOLD("Error:")] Call reason must be longer than 12 characters.")
		return

	var/auth = system.current_user.get_auth()
	var/list/packet_data = packetv2(
		null,
		commaster.comms_dish_net_id,
		payload = list(
			PKT_ARG_CMD = NET_COMMAND_CALL_SHUTTLE,
			PKT_ARG_AUTH = auth,
			PKT_ARG_CALL_REASON = reason,
		)
	)
	var/datum/signal/packet = new(null, packet_data, transmission_method = TRANSMISSION_WIRE)
	packet.logging_ckey = usr?.ckey

	system.get_computer().post_signal(packet)
	system.println("Sent!")

/datum/shell_command/commaster/connect
	aliases = list("connect", "c",)

/datum/shell_command/commaster/connect/exec(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/c4_file/terminal_program/program, list/arguments, list/options)
	astype(program, /datum/c4_file/terminal_program/commaster).find_comms_dish(system)
