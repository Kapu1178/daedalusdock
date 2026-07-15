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

/datum/shell_command/commaster/recall
	aliases = list("r", "recall",)

/datum/shell_command/commaster/recall/exec(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/c4_file/terminal_program/program, list/arguments, list/options)
	var/datum/c4_file/terminal_program/commaster/commaster = program
	var/obj/machinery/power/data_terminal/netjack = commaster.get_netjack()

	if(!netjack)
		system.print_error("[ANSI_WRAP_BOLD("Error:")] Console is not connected to the wirenet.")
		return

	var/auth = system.current_user.get_auth()
	var/list/packet_data = packetv2(
		null,
		commaster.comms_dish_net_id,
		payload = list(
			PKT_ARG_CMD = NET_COMMAND_RECALL_SHUTTLE,
			PKT_ARG_AUTH = auth,
		)
	)
	var/datum/signal/packet = new(null, packet_data, transmission_method = TRANSMISSION_WIRE)
	packet.logging_ckey = usr?.ckey

	system.get_computer().post_signal(packet)
	system.println("Sent!")

/datum/shell_command/commaster/change_sec_level
	aliases = list("security_level", "sl")

/datum/shell_command/commaster/change_sec_level/exec(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/c4_file/terminal_program/program, list/arguments, list/options)
	if(!length(arguments))
		system.print_error("[ANSI_WRAP_BOLD("Error:")] No security level argument provided. Run 'help security_level' for usage.")
		return

	var/new_level = lowertext(arguments[1])
	if(!(new_level in list("green", "blue")))
		system.print_error("[ANSI_WRAP_BOLD("Error:")] Invalid security level provided. Valid security levels: 'green', 'blue'.")
		return

	if (SSsecurity_level.current_level == seclevel2num(new_level))
		return

	set_security_level(new_level)

	log_game("[key_name(usr)] has changed the security level to [new_level] with [src] at [AREACOORD(usr)].")
	message_admins("[ADMIN_LOOKUPFLW(usr)] has changed the security level to [new_level] with [src] at [AREACOORD(usr)].")
	deadchat_broadcast(" has changed the security level to [new_level] with [src] at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type=DEADCHAT_ANNOUNCEMENT)

/datum/shell_command/commaster/set_status_display
	aliases = list("status")

/datum/shell_command/commaster/set_status_display/exec(datum/c4_file/terminal_program/operating_system/thinkdos/system, datum/c4_file/terminal_program/program, list/arguments, list/options)
	var/datum/c4_file/terminal_program/commaster/commaster = program
	var/obj/item/peripheral/network_card/wireless/adapter = commaster.get_adapter()

	if(!adapter)
		system.print_error("[ANSI_WRAP_BOLD("Error:")] No wireless adapter installed.")
		return

	if(!(length(arguments) || length(options)))
		system.print_error("[ANSI_WRAP_BOLD("Error:")] No argument(s) provided. Run 'help status' for usage.")
		return

	if(length(arguments))
		if(arguments[1] == "message")
			var/line_one
			var/line_two

			var/datum/signal/packet = new(
				null,
				packetv2(
					null,
					payload = list(
						PKT_ARG_CMD = NET_COMMAND_STATDISPLAY_SET,
						PKT_ARG_STATDISPLAY_MODE = "message",
					)
				)
			)

			if(length(arguments) <= 1)
				adapter.post_signal(packet)
				return

			// ok here goes
			var/list/messages = splittext(jointext(arguments.Copy(2), " "), "\"")
			if(length(messages) == 1)
				// set status displays to no message (no quote-wrapped argument)
				adapter.post_signal(packet)
				return

			// Lop off everything other than up to 2 quote-enclosed arguments.
			messages = messages.Copy(2, min(length(messages), 5))

			// If there were two messages in the command, there will be an entry representing any characters between the two enclosed arguments.
			// Remove it.
			if(length(messages) == 3)
				messages -= messages[2]

			if(length(messages))
				line_one = reject_bad_text(messages[1] || "", MAX_STATUS_LINE_LENGTH)
				if(length(messages) == 2)
					line_two = reject_bad_text(messages[2] || "", MAX_STATUS_LINE_LENGTH)

			packet.data[PKT_PAYLOAD]["msg1"] = line_one
			packet.data[PKT_PAYLOAD]["msg2"] = line_two

			adapter.post_signal(packet, frequency = FREQ_STATUS_DISPLAYS)

		// if ("setStatusMessage")
		// 	if (!authenticated(usr))
		// 		return
		// 	var/line_one = reject_bad_text(params["lineOne"] || "", MAX_STATUS_LINE_LENGTH)
		// 	var/line_two = reject_bad_text(params["lineTwo"] || "", MAX_STATUS_LINE_LENGTH)
		// 	post_status("alert", "blank")
		// 	post_status("message", line_one, line_two)
		// 	last_status_display = list(line_one, line_two)
		// 	playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
		// if ("setStatusPicture")
		// 	if (!authenticated(usr))
		// 		return
		// 	var/picture = params["picture"]
		// 	if (!(picture in approved_status_pictures))
		// 		return
		// 	if(picture in state_status_pictures)
		// 		post_status(picture)
		// 	else
		// 		post_status("alert", picture)
		// 	playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
