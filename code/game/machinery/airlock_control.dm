#define AIRLOCK_CONTROL_RANGE 5

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	/// The current state of the airlock, used to construct the airlock overlays
	var/airlock_state
	var/frequency
	var/datum/radio_frequency/radio_connection


/obj/machinery/door/airlock/receive_signal(datum/signal/signal)
	SHOULD_CALL_PARENT(FALSE) //TODO: RECONCILE TAGS AND NETIDS
	if(!signal)
		return

	if(id_tag != signal.data["tag"] || !signal.data["command"])
		return

	switch(signal.data["command"])
		if("open")
			open(TRUE)

		if("close")
			close(TRUE)

		if("unlock")
			unbolt()
			update_appearance()

		if("lock")
			bolt()
			update_appearance()

		if("secure_open")
			secure_open()
			return

		if("secure_close")
			secure_close()
			return

	send_status()

/obj/machinery/door/airlock/proc/secure_close()
	set waitfor = FALSE
	unbolt()
	close(TRUE)
	sleep(2)
	bolt()
	update_appearance()
	send_status()

/obj/machinery/door/airlock/proc/secure_open()
	set waitfor = FALSE
	unbolt()
	update_appearance()
	sleep(2)
	open(TRUE)
	bolt()
	update_appearance()
	send_status()

/obj/machinery/door/airlock/proc/send_status()
	if(radio_connection)
		var/datum/signal/signal = new(src, list(
			"tag" = id_tag,
			"timestamp" = world.time,
			"door_status" = density ? "closed" : "open",
			"lock_status" = locked ? "locked" : "unlocked"
		))
		radio_connection.post_signal(signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)


/obj/machinery/door/airlock/open(surpress_send)
	. = ..()
	if(!surpress_send)
		send_status()


/obj/machinery/door/airlock/close(surpress_send)
	. = ..()
	if(!surpress_send)
		send_status()


/obj/machinery/door/airlock/proc/set_frequency(new_frequency)
	SSpackets.remove_object(src, frequency)
	if(new_frequency)
		frequency = new_frequency
		radio_connection = SSpackets.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/door/airlock/Destroy()
	if(frequency)
		SSpackets.remove_object(src,frequency)
	return ..()

/obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	base_icon_state = "airlock_sensor"
	name = "airlock sensor"
	resistance_flags = FIRE_PROOF

	power_channel = AREA_USAGE_ENVIRON

	var/master_tag
	var/frequency = FREQ_AIRLOCK_CONTROL

	var/datum/radio_frequency/radio_connection

	var/on = TRUE
	var/alert = FALSE

/obj/machinery/airlock_sensor/incinerator_ordmix
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_SENSOR
	master_tag = INCINERATOR_ORDMIX_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/incinerator_atmos
	id_tag = INCINERATOR_ATMOS_AIRLOCK_SENSOR
	master_tag = INCINERATOR_ATMOS_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/update_icon_state()
	if(!on)
		icon_state = "[base_icon_state]_off"
	else
		if(alert)
			icon_state = "[base_icon_state]_alert"
		else
			icon_state = "[base_icon_state]_standby"
	return ..()

/obj/machinery/airlock_sensor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/datum/signal/signal = new(src, list(
		"tag" = master_tag,
		"command" = "cycle"
	))

	radio_connection.post_signal(signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	z_flick("airlock_sensor_cycle", src)

/obj/machinery/airlock_sensor/process()
	if(on)
		var/datum/gas_mixture/air_sample = loc.unsafe_return_air()
		var/pressure = round(air_sample.returnPressure(),0.1)
		alert = (pressure < ONE_ATMOSPHERE*0.8)

		var/datum/signal/signal = new(src, list(
			"tag" = id_tag,
			"timestamp" = world.time,
			"pressure" = num2text(pressure)
		))

		radio_connection.post_signal(signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

	update_appearance()

/obj/machinery/airlock_sensor/proc/set_frequency(new_frequency)
	SSpackets.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSpackets.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/airlock_sensor/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/machinery/airlock_sensor/Destroy()
	SSpackets.remove_object(src,frequency)
	return ..()
