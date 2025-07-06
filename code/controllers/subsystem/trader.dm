SUBSYSTEM_DEF(trader)
	name = "Traders"
	init_order = INIT_ORDER_TRADER

	/// The currently loaded ship.
	var/obj/docking_port/mobile/current_ship
	/// Station-side docking port for the trade ship.
	var/obj/docking_port/stationary/station_dock

/datum/controller/subsystem/trader/Initialize(start_timeofday)
	station_dock = SSshuttle.getDock("tradeship_home")

	spawn_trader("trader_flock")
	dock_trader()
	return ..()

/datum/controller/subsystem/trader/fire(resumed)
	return

/// Spawns the trader into a transit zone, replacing the previous one.
/datum/controller/subsystem/trader/proc/spawn_trader(shuttle_id)
	current_ship = SSshuttle.action_load(SSmapping.shuttle_templates[shuttle_id], replace = TRUE)

/// Dock the current trader to the station.
/datum/controller/subsystem/trader/proc/dock_trader()
	current_ship.Dock(station_dock)
