/proc/possess(obj/O in world)
	set name = "Possess Obj"
	set category = "Object"

	if((O.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(usr, "[O] is too powerful for you to possess.", confidential = TRUE)
		return

	var/turf/T = get_turf(O)

	if(T)
		log_admin("[key_name(usr)] has possessed [O] ([O.type]) at [AREACOORD(T)]")
		message_admins("[key_name(usr)] has possessed [O] ([O.type]) at [AREACOORD(T)]")
	else
		log_admin("[key_name(usr)] has possessed [O] ([O.type]) at an unknown location")
		message_admins("[key_name(usr)] has possessed [O] ([O.type]) at an unknown location")

	if(!usr.control_object) //If you're not already possessing something...
		usr.name_archive = usr.real_name

	usr.forceMove(O)
	usr.set_real_name(O.name)
	usr.reset_perspective(O)
	usr.control_object = O
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Possess Object") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/release()
	set name = "Release Obj"
	set category = "Object"

	if(!usr.control_object) //lest we are banished to the nullspace realm.
		return

	if(usr.name_archive) //if you have a name archived
		usr.set_real_name(usr.name_archive)
		usr.name_archive = ""
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			H.update_appearance(UPDATE_NAME)

	usr.forceMove(get_turf(usr.control_object))
	usr.reset_perspective()
	usr.control_object = null
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Release Object") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/givetestverbs(mob/M in GLOB.mob_list)
	set desc = "Give this guy possess/release verbs"
	set category = "Debug"
	set name = "Give Possessing Verbs"
	add_verb(M, GLOBAL_PROC_REF(possess))
	add_verb(M, GLOBAL_PROC_REF(release))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Possessing Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
