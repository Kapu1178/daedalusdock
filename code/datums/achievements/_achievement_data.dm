///Datum that handles
/datum/achievement_data
	///Ckey of this achievement data's owner
	var/owner_ckey
	///Up to date list of all achievements and their info.
	var/data = list()
	///Original status of achievement.
	var/original_cached_data = list()
	///Have we done our set-up yet?
	var/initialized = FALSE

/datum/achievement_data/New(ckey)
	owner_ckey = ckey
	if(SSachievements.initialized && !initialized)
		InitializeData()

/datum/achievement_data/proc/InitializeData()
	initialized = TRUE
	load_all_achievements() //So we know which achievements we have unlocked so far.

///Gets list of changed rows in MassInsert format
/datum/achievement_data/proc/get_changed_data()
	. = list()
	for(var/T in data)
		var/datum/award/A = SSachievements.awards[T]
		if(data[T] != original_cached_data[T])//If our data from before is not the same as now, save it to db.
			var/deets = A.get_changed_rows(owner_ckey,data[T])
			if(deets)
				. += list(deets)

/datum/achievement_data/proc/load_all_achievements()
	set waitfor = FALSE

	var/list/kv = list()
	var/datum/db_query/Query = SSdbcore.NewQuery(
		"SELECT achievement_key,value FROM [format_table_name("achievements")] WHERE ckey = :ckey",
		list("ckey" = owner_ckey)
	)
	if(!Query.Execute())
		qdel(Query)
		return
	while(Query.NextRow())
		var/key = Query.item[1]
		var/value = text2num(Query.item[2])
		kv[key] = value
	qdel(Query)

	for(var/T in subtypesof(/datum/award))
		var/datum/award/A = SSachievements.awards[T]
		if(!A || !A.name) //Skip abstract achievements types
			continue
		if(!data[T])
			data[T] = A.parse_value(kv[A.database_id])
			original_cached_data[T] = data[T]

///Updates local cache with db data for the given achievement type if it wasn't loaded yet.
/datum/achievement_data/proc/get_data(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	if(!A.name)
		return FALSE
	if(!data[achievement_type])
		data[achievement_type] = A.load(owner_ckey)
		original_cached_data[achievement_type] = data[achievement_type]

///Unlocks an achievement of a specific type. achievement type is a typepath to the award, user is the mob getting the award, and value is an optional value to be used for defining a score to add to the leaderboard
/datum/achievement_data/proc/unlock(achievement_type, mob/user, value = 1)
	set waitfor = FALSE

	if(!SSachievements.achievements_enabled)
		return

	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type) //Get the current status first if necessary
	if(istype(A, /datum/award/achievement))
		if(data[achievement_type]) //You already unlocked it so don't bother running the unlock proc
			return

		data[achievement_type] = TRUE
		A.on_unlock(user) //Only on default achievement, as scores keep going up.

	else if(istype(A, /datum/award/score))
		data[achievement_type] += value

///Getter for the status/score of an achievement
/datum/achievement_data/proc/get_achievement_status(achievement_type)
	return data[achievement_type]

///Resets an achievement to default values.
/datum/achievement_data/proc/reset(achievement_type)
	if(!SSachievements.achievements_enabled)
		return
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type)
	data[achievement_type] = A.default_value

/datum/achievement_data/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/achievements),
	)

/datum/achievement_data/ui_state(mob/user)
	return GLOB.always_state

/datum/achievement_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Achievements")
		ui.open()

/datum/achievement_data/ui_data(mob/user)
	var/ret_data = list() // screw standards (qustinnus you must rename src.data ok)
	ret_data["achievements"] = list()
	ret_data["user_key"] = user.ckey

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
	ret_data["undiscovered_icon_class"] = assets.icon_class_name("undiscovered")

	//This should be split into static data later
	for(var/achievement_type in SSachievements.awards)
		if(isabstract(SSachievements.awards[achievement_type])) //No name? we a subtype.
			continue
		if(isnull(data[achievement_type])) //We're still loading
			continue

		var/datum/award/award_datum = SSachievements.awards[achievement_type]
		var/list/this = list(
			"name" = award_datum.name,
			"desc" = award_datum.desc,
			"category" = award_datum.category,
			"icon_class" = assets.icon_class_name(award_datum.icon),
			"value" = data[achievement_type],
			"score" = ispath(achievement_type,/datum/award/score),
			"hidden" = award_datum.hidden_until_unlocked,
			)
		ret_data["achievements"] += list(this)

	return ret_data

/datum/achievement_data/ui_static_data(mob/user)
	. = ..()
	.["categories"] = SSachievements.achievement_category_data

/client/verb/checkachievements()
	set category = "OOC"
	set name = "View Achievements"
	set desc = "See all of your achievements."

	persistent_client.achievements.ui_interact(usr)
