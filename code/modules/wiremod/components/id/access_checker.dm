/obj/item/circuit_component/compare/access
	display_name = "Access Checker"
	desc = "Performs a basic comparison between two numerical lists, with additional functions that help in using it to check access on IDs."
	category = "ID"

	input_port_amount = 0 //Uses custom ports for its comparisons

	/// A list of the accesses to check
	var/datum/port/input/subject_accesses

	/// A list of the accesses required to return true
	var/datum/port/input/required_accesses

	/// Whether to check for all or any of the required accesses
	var/datum/port/input/check_any

	ui_buttons = list("id-card" = "access")

/obj/item/circuit_component/compare/access/Initialize(mapload)
	. = ..()
	gen_access()

/obj/item/circuit_component/compare/access/get_ui_notices()
	. = ..()
	. += create_ui_notice("When \"Check Any\" is true, returns true if \"Access To Check\" contains ANY value in \"Required Access\".", "orange", "info")
	. += create_ui_notice("When \"Check Any\" is false, returns true only if \"Access To Check\" contains ALL values in \"Required Access\".", "orange", "info")

/obj/item/circuit_component/compare/access/populate_custom_ports()
	subject_accesses = add_input_port("Access To Check", PORT_TYPE_LIST(PORT_TYPE_NUMBER))
	required_accesses = add_input_port("Required Access", PORT_TYPE_LIST(PORT_TYPE_NUMBER))
	check_any = add_input_port("Check Any", PORT_TYPE_NUMBER)

/obj/item/circuit_component/compare/access/save_data_to_list(list/component_data)
	. = ..()
	component_data["input_ports_stored_data"] = list(required_accesses.name = list("stored_data" = required_accesses.value))

/obj/item/circuit_component/compare/access/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	RegisterSignal(added_to, COMSIG_CIRCUIT_POST_LOAD, PROC_REF(on_post_load))

/obj/item/circuit_component/compare/access/removed_from(obj/item/integrated_circuit/removed_from)
	UnregisterSignal(removed_from, COMSIG_CIRCUIT_POST_LOAD)
	return ..()

/obj/item/circuit_component/compare/access/proc/on_post_load(datum/source)
	regenerate_access()

/obj/item/circuit_component/compare/access/proc/regenerate_access()
	var/check_any_value = check_any.value
	var/list/required_accesses_list = required_accesses.value
	if(!islist(required_accesses_list))
		return
	if(check_any_value)
		LAZYCLEARLIST(req_access)
		req_one_access = required_accesses_list.Copy()
	else
		LAZYCLEARLIST(req_one_access)
		req_access = required_accesses_list.Copy()

/obj/item/circuit_component/compare/access/do_comparisons(list/ports)
	return check_access_list(subject_accesses.value)

/obj/item/circuit_component/compare/access/ui_perform_action(mob/user, action)
	if(length(required_accesses.connected_ports))
		balloon_alert(user, "Disconnect port before manually configuring!")
		return
	interact(user)

/obj/item/circuit_component/compare/access/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CircuitAccessChecker", display_name)
		ui.open()

/obj/item/circuit_component/compare/access/ui_static_data(mob/user)
	var/list/data = list()

	var/list/regions = list()
	var/list/tgui_region_data = SSid_access.tgui_access_groups
	for(var/region in SSid_access.station_groups)
		regions += tgui_region_data[region]
	if(parent?.admin_only)
		regions += tgui_region_data[/datum/access_group/centcom]
		regions += tgui_region_data[/datum/access_group/all]
	data["regions"] = regions
	return data

/obj/item/circuit_component/compare/access/ui_data(mob/user)
	var/list/data = list()
	data["accesses"] = required_accesses.value
	data["oneAccess"] = check_any.value
	return data

/obj/item/circuit_component/compare/access/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_all")
			required_accesses.set_value(list())
			check_any.set_value(0)
			. = TRUE
		if("grant_all")
			required_accesses.set_value(SSid_access.get_access_for_group(list(/datum/access_group/station/all)))
			. = TRUE
		if("one_access")
			check_any.set_value(!check_any.value)
			. = TRUE
		if("set")
			var/list/required_accesses_list = required_accesses.value
			var/list/new_accesses_value = LAZYCOPY(required_accesses_list)
			var/access = text2num(params["access"])
			if (!(access in new_accesses_value))
				new_accesses_value += access
			else
				new_accesses_value -= access
			required_accesses.set_value(new_accesses_value)
			. = TRUE
		if("grant_region")
			var/list/required_accesses_list = required_accesses.value
			var/list/required_accesses_value = LAZYCOPY(required_accesses_list)
			var/region = params["region"]
			if(isnull(region))
				return
			required_accesses.set_value(required_accesses_value | SSid_access.get_access_for_group(list(region)))
			. = TRUE
		if("deny_region")
			var/list/required_accesses_list = required_accesses.value
			var/list/required_accesses_value = LAZYCOPY(required_accesses_list)
			var/region = params["region"]
			if(isnull(region))
				return
			required_accesses.set_value(required_accesses_value - SSid_access.get_access_for_group(list(region)))
			. = TRUE
	if(.)
		regenerate_access()
		SStgui.update_uis(parent)
