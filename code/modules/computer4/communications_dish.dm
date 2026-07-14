/obj/machinery/communications_dish
	name = "communications dish"
	icon = 'goon/icons/obj/comms_dish.dmi'
	icon_state = "commdish"

	use_power = NO_POWER_USE

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

/obj/machinery/communications_dish/proc/call_shuttle(datum/signal/signal)
	var/mob/probable_user = get_mob_by_ckey(signal.logging_ckey)
	var/potential_error = SSshuttle.packetRequestEvac(probable_user, signal.data[PKT_PAYLOAD][PKT_ARG_CALL_REASON])

	if(potential_error != TRUE)
		var/datum/signal/packet = new(src, packetv2(net_id, signal.data[PKT_HEAD_SOURCE_ADDRESS], payload = list("commaster_failure" = potential_error)))
		post_signal(packet)
