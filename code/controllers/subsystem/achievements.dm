SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS
	var/achievements_enabled = FALSE

	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

	/// TGUI data.
	var/list/achievement_category_data = list()

/datum/controller/subsystem/achievements/Initialize(timeofday)
	if(!SSdbcore.Connect())
		return ..()

	achievements_enabled = TRUE

	for(var/T in subtypesof(/datum/award/achievement))
		var/instance = new T
		achievements[T] = instance
		awards[T] = instance

	for(var/T in subtypesof(/datum/award/score))
		var/instance = new T
		scores[T] = instance
		awards[T] = instance

	for(var/datum/award/award_type as anything in subtypesof(/datum/award))
		if(isabstract(award_type))
			continue
		achievement_category_data |= initial(award_type.category)

	update_metadata()

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!C.persistent_client.achievements.initialized)
			C.persistent_client.achievements.InitializeData()

	return ..()

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_db()

/datum/controller/subsystem/achievements/proc/save_achievements_to_db()
	var/list/cheevos_to_save = list()
	for(var/ckey in GLOB.persistent_clients_by_ckey)
		var/datum/persistent_client/PD = GLOB.persistent_clients_by_ckey[ckey]
		if(!PD || !PD.achievements)
			continue
		cheevos_to_save += PD.achievements.get_changed_data()
	if(!length(cheevos_to_save))
		return
	SSdbcore.MassInsert(format_table_name("achievements"),cheevos_to_save,duplicate_key = TRUE)

//Update the metadata if any are behind
/datum/controller/subsystem/achievements/proc/update_metadata()
	var/list/current_metadata = list()
	//select metadata here
	var/datum/db_query/Q = SSdbcore.NewQuery("SELECT achievement_key,achievement_version FROM [format_table_name("achievement_metadata")]")
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return
	else
		while(Q.NextRow())
			current_metadata[Q.item[1]] = text2num(Q.item[2])
		qdel(Q)

	var/list/to_update = list()
	for(var/T in awards)
		var/datum/award/A = awards[T]
		if(!A.database_id)
			continue
		if(!current_metadata[A.database_id] || current_metadata[A.database_id] < A.achievement_version)
			to_update += list(A.get_metadata_row())

	if(to_update.len)
		SSdbcore.MassInsert(format_table_name("achievement_metadata"),to_update,duplicate_key = TRUE)
