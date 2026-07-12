/obj/machinery/communications_dish
	name = "communications dish"

	network_flags = NETWORK_FLAGS_STANDARD_CONNECTION
	net_class = NETCLASS_COMMS_DISH

/obj/machinery/communications_dish/receive_signal(datum/signal/signal)
	. = ..()
	if(. == RECEIVE_SIGNAL_FINISHED)
		return
