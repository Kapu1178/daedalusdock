/obj/docking_port/mobile/assault_pod
	name = "assault pod"
	id = "steel_rain"
	dwidth = 3
	width = 7
	height = 7

/obj/docking_port/mobile/assault_pod/request(obj/docking_port/stationary/S)
	if(!(z in SSmapping.levels_by_trait(ZTRAIT_STATION))) //No launching pods that have already launched
		return ..()


/obj/docking_port/mobile/assault_pod/post_dock(obj/docking_port/stationary/new_dock)
	. = ..()
	if(!istype(new_dock, /obj/docking_port/stationary/transit))
		playsound(get_turf(src.loc), 'sound/effects/explosion1.ogg',50,TRUE)



/obj/item/assault_pod
	name = "Assault Pod Targeting Device"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "Used to select a landing zone for assault pods."
	var/shuttle_id = "steel_rain"
	var/dwidth = 3
	var/dheight = 0
	var/width = 7
	var/height = 7
	var/lz_dir = 1


/obj/item/assault_pod/attack_self(mob/living/user)
	var/target_area = tgui_input_list(user, "Area to land", "Landing Zone", GLOB.teleportlocs)
	if(isnull(target_area))
		return
	if(isnull(GLOB.teleportlocs[target_area]))
		return
	var/area/picked_area = GLOB.teleportlocs[target_area]
	if(!src || QDELETED(src))
		return

	var/list/turfs = get_area_turfs(picked_area)
	if (!length(turfs))
		return
	var/turf/T = pick(turfs)
	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = "assault_pod([REF(src)])"
	landing_zone.port_destinations = "assault_pod([REF(src)])"
	landing_zone.name = "Landing Zone"
	landing_zone.dwidth = dwidth
	landing_zone.dheight = dheight
	landing_zone.width = width
	landing_zone.height = height
	landing_zone.setDir(lz_dir)

	for(var/obj/machinery/computer/shuttle/S as anything in INSTANCES_OF(/obj/machinery/computer/shuttle))
		if(S.shuttleId == shuttle_id)
			S.possible_destinations = "[landing_zone.id]"

	to_chat(user, span_notice("Landing zone set."))

	qdel(src)
