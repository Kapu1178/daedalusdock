/obj/machinery/communications_dish
	name = "communications dish"

	network_flags = NETWORK_FLAGS_STANDARD_CONNECTION
	net_class = NETCLASS_COMMS_DISH

/obj/machinery/communications_dish/receive_signal(datum/signal/signal)
	. = ..()
	if(. == RECEIVE_SIGNAL_FINISHED)
		return

	var/list/payload = signal.data[PKT_PAYLOAD]
	switch(payload[PKT_ARG_CMD])
		if(NET_COMMAND_CALL_SHUTTLE)
			call_shuttle(signal)
			return

	//	SSshuttle.mobRequestEvac(usr, reason)

/obj/machinery/communications_dish/proc/call_shuttle(datum/signal/signal)
	var/reason = trim(html_encode(signal.data[PKT_PAYLOAD][PKT_ARG_CALL_REASON]))
