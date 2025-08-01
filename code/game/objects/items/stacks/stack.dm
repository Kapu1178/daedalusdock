//stack recipe placement check types
/// Checks if there is an object of the result type in any of the cardinal directions
#define STACK_CHECK_CARDINALS "cardinals"
/// Checks if there is an object of the result type within one tile
#define STACK_CHECK_ADJACENT "adjacent"

/* Stack type objects!
 * Contains:
 * Stacks
 * Recipe datum
 * Recipe list datum
 */

/*
 * Stacks
 */

/obj/item/stack
	icon = 'icons/obj/stack_objects.dmi'
	maptext_x = -4
	maptext_y = 2

	material_modifier = 0.05 //5%, so that a 50 sheet stack has the effect of 5k materials instead of 100k.
	max_integrity = 100

	var/list/datum/stack_recipe/recipes
	/// The name of one piece of the stack.
	var/singular_name
	/// The gender of a single instance of the stack.
	var/singular_gender = NEUTER

	/// The name used to describe the group of objects.
	var/stack_name = "stack"
	/// The gender of the stack.
	var/multiple_gender = PLURAL

	/// The amount of STUFF currently in the stack.
	var/amount = 1
	/// The maximum amount of STUFF this stack can hold. also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/max_amount = 50

	/// This path and its children should merge with this stack, defaults to src.type
	var/merge_type = null
	/// The weight class the stack should have at amount > 2/3rds max_amount
	var/full_w_class = WEIGHT_CLASS_NORMAL
	/// If FALSE, the stack changes icon state based on the ratio of amount to max amount.
	var/novariants = TRUE
	/// If TRUE, dynamically adjust the name of the item based on singular/plural quantities.
	var/dynamically_set_name = FALSE
	/// list that tells you how much is in a single unit.
	var/list/mats_per_unit
	/// Datum material type that this stack is made of
	var/material_type

	var/datum/robot_energy_storage/source
	var/cost = 1 // How much energy from storage it costs
	/// It's TRUE if module is used by a cyborg, and uses its storage
	var/is_cyborg = FALSE

	//NOTE: When adding grind_results, the amounts should be for an INDIVIDUAL ITEM - these amounts will be multiplied by the stack size in on_grind()
	var/obj/structure/table/tableVariant // we tables now (stores table variant to be built from this stack)

	// The following are all for medical treatment, they're here instead of /stack/medical because sticky tape can be used as a makeshift bandage or splint
	/// If set and this used as a splint for a broken bone wound, this is used as a modifier for applicable slowdowns (lower = better) (also for speeding up burn recoveries)
	var/splint_slowdown = null
	/// Like splint_factor but for burns instead of bone wounds. This is a multiplier used to speed up burn recoveries
	var/burn_cleanliness_bonus

	/// How much blood this stack can absorb until the owner starts loosing blood again.
	var/absorption_capacity = 0
	/// How much this stack reduces blood flow, multiplier
	var/absorption_rate_modifier = 1

	/// Amount of matter for RCD
	var/matter_amount = 0
	/// Does this stack require a unique girder in order to make a wall?
	var/has_unique_girder = FALSE

/obj/item/stack/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1, absorption_capacity)
	if(new_amount != null)
		amount = new_amount
	while(amount > max_amount)
		amount -= max_amount
		new type(loc, max_amount, FALSE)
	if(!merge_type)
		merge_type = type

	if(absorption_capacity)
		src.absorption_capacity = absorption_capacity

	// Not typeinfo() for speed reasons. Hot ass code!
	var/datum/typeinfo/atom/typeinfo = __typeinfo_cache[type] ||= new __typeinfo_path

	if(LAZYLEN(mat_override))
		set_mats_per_unit(mat_override, mat_amt)
	else if(LAZYLEN(mats_per_unit))
		set_mats_per_unit(mats_per_unit, 1)
	else if(LAZYLEN(typeinfo.default_materials))
		set_mats_per_unit(typeinfo.default_materials, amount ? 1/amount : 1)

	. = ..()
	// HELLO THIS IS KAPU. THIS IS BROKEN.
	// BECAUSE ON DAEDALUS ALL MOVABLES CALL LOC.ENTERED(SRC) POST-INITIALIZE, STACKS WILL ALWAYS MERGE.
	if(merge)
		for(var/obj/item/stack/item_stack in loc)
			if(item_stack == src)
				continue
			if(can_merge(item_stack))
				INVOKE_ASYNC(src, PROC_REF(merge_without_del), item_stack)
				if(is_zero_amount(delete_if_zero = FALSE))
					return INITIALIZE_HINT_QDEL
	var/list/temp_recipes = get_main_recipes()
	recipes = temp_recipes.Copy()
	if(material_type)
		var/datum/material/M = GET_MATERIAL_REF(material_type) //First/main material
		for(var/i in M.categories)
			switch(i)
				if(MAT_CATEGORY_BASE_RECIPES)
					var/list/temp = SSmaterials.base_stack_recipes.Copy()
					recipes += temp
				if(MAT_CATEGORY_RIGID)
					var/list/temp = SSmaterials.rigid_stack_recipes.Copy()
					recipes += temp
	update_weight()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_movable_entered_occupied_turf),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/stack/update_appearance(updates)
	. = ..()
	update_gender()
	update_maptext()

/obj/item/stack/update_name(updates)
	if(dynamically_set_name)
		if(amount > 1)
			name = initial(name)
		else
			name = singular_name
	return ..()

/// Update the gender var based on if the stack contains 1 or more items.
/obj/item/stack/proc/update_gender() // Maybe the funniest proc name ever
	if(amount > 1)
		gender = multiple_gender
	else
		gender = singular_gender

/obj/item/stack/equipped(mob/user, slot, initial)
	. = ..()
	update_maptext()

/obj/item/stack/unequipped(mob/user, silent)
	. = ..()
	update_maptext()

/obj/item/stack/on_enter_storage(datum/storage/master_storage)
	. = ..()
	update_maptext()

/obj/item/stack/on_exit_storage(datum/storage/master_storage)
	. = ..()
	update_maptext()

/// Set the maptext for the item that shows how much junk is inside the trunk.
/obj/item/stack/proc/update_maptext()
	if(item_flags & (IN_INVENTORY|IN_STORAGE))
		maptext = MAPTEXT("<span style='text-align: right'>[amount]</span>")
	else
		maptext = null

/obj/item/stack/examine_properties(mob/user)
	. = ..()
	. += PROPERTY_STACKABLE

/** Sets the amount of materials per unit for this stack.
 *
 * Arguments:
 * - [mats][/list]: The value to set the mats per unit to.
 * - multiplier: The amount to multiply the mats per unit by. Defaults to 1.
 */
/obj/item/stack/proc/set_mats_per_unit(list/mats, multiplier=1)
	mats_per_unit = SSmaterials.FindOrCreateMaterialCombo(mats, multiplier)
	update_custom_materials()

/** Updates the custom materials list of this stack.
 */
/obj/item/stack/proc/update_custom_materials()
	set_custom_materials(mats_per_unit, amount, is_update=TRUE)

/**
 * Override to make things like metalgen accurately set custom materials
 */
/obj/item/stack/set_custom_materials(list/materials, multiplier=1, is_update=FALSE)
	return is_update ? ..() : set_mats_per_unit(materials, multiplier/(amount || 1))


/obj/item/stack/do_grind(datum/reagents/target_holder, mob/user)
	var/current_amount = get_amount()
	if(current_amount <= 0 || QDELETED(src)) //just to get rid of this 0 amount/deleted stack we return success
		return TRUE

	if(reagents)
		reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
	var/available_volume = target_holder.maximum_volume - target_holder.total_volume

	//compute total volume of reagents that will be occupied by grind_results
	var/total_volume = 0
	for(var/reagent in grind_results)
		total_volume += grind_results[reagent]

	//compute number of pieces(or sheets) from available_volume
	var/available_amount = min(current_amount, round(available_volume / total_volume))
	if(available_amount <= 0)
		return FALSE

	//Now transfer the grind results scaled by available_amount
	var/list/grind_reagents = grind_results.Copy()
	for(var/reagent in grind_reagents)
		grind_reagents[reagent] *= available_amount
	target_holder.add_reagent_list(grind_reagents)

	/**
	 * use available_amount of sheets/pieces, return TRUE only if all sheets/pieces of this stack were used
	 * we don't delete this stack when it reaches 0 because we expect the all in one grinder, etc to delete
	 * this stack if grinding was successful
	 */
	use(available_amount, check = FALSE)
	return available_amount == current_amount

/obj/item/stack/grind_requirements()
	if(is_cyborg)
		to_chat(usr, span_warning("[src] is electronically synthesized in your chassis and can't be ground up!"))
		return
	return TRUE

/obj/item/stack/proc/get_main_recipes()
	SHOULD_CALL_PARENT(TRUE)
	return list()//empty list

/obj/item/stack/proc/update_weight()
	var/new_w_class
	if(amount <= (max_amount * (1/3)))
		new_w_class = clamp(full_w_class-2, WEIGHT_CLASS_TINY, full_w_class)
	else if (amount <= (max_amount * (2/3)))
		new_w_class = clamp(full_w_class-1, WEIGHT_CLASS_TINY, full_w_class)
	else
		new_w_class = full_w_class

	set_weight_class(new_w_class)

/obj/item/stack/update_icon_state()
	if(novariants)
		return ..()
	if(amount <= (max_amount * (1/3)))
		icon_state = initial(icon_state)
		return ..()
	if (amount <= (max_amount * (2/3)))
		icon_state = "[initial(icon_state)]_2"
		return ..()
	icon_state = "[initial(icon_state)]_3"
	return ..()

/obj/item/stack/examine(mob/user)
	. = ..()
	var/plural = get_amount()>1
	if(is_cyborg)
		if(singular_name)
			. += span_notice("There is enough energy for [get_amount()] [singular_name]\s.")
		else
			. += span_notice("There is enough energy for [get_amount()].")
		return

	if(singular_name)
		if(plural)
			. += span_notice("There are [get_amount()] [singular_name]\s in the [stack_name].")

	else if(plural)
		. += span_notice("There are [get_amount()] in the [stack_name].")

	if(absorption_capacity < initial(absorption_capacity))
		if(absorption_capacity == 0)
			. += span_alert("[plural ? "They are" : "It is"] drenched in blood, this won't be a suitable bandage.")
		else
			. += span_notice("[plural ? "They are" : "It is"] covered in blood.")

/obj/item/stack/proc/get_amount()
	if(is_cyborg)
		. = round(source?.energy / cost)
	else
		. = (amount)

/**
 * Builds all recipes in a given recipe list and returns an association list containing them
 *
 * Arguments:
 * * recipe_to_iterate - The list of recipes we are using to build recipes
 */
/obj/item/stack/proc/recursively_build_recipes(list/recipe_to_iterate)
	var/list/L = list()
	for(var/recipe in recipe_to_iterate)
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L["[R.title]"] = recursively_build_recipes(R.recipes)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L["[R.title]"] = build_recipe(R)
	return L

/**
 * Returns a list of properties of a given recipe
 *
 * Arguments:
 * * R - The stack recipe we are using to get a list of properties
 */
/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = "\ref[R]",
	)

/**
 * Checks if the recipe is valid to be used
 *
 * Arguments:
 * * R - The stack recipe we are checking if it is valid
 * * recipe_list - The list of recipes we are using to check the given recipe
 */
/obj/item/stack/proc/is_valid_recipe(datum/stack_recipe/R, list/recipe_list)
	for(var/S in recipe_list)
		if(S == R)
			return TRUE
		if(istype(S, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/L = S
			if(is_valid_recipe(R, L.recipes))
				return TRUE
	return FALSE

/obj/item/stack/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/stack/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Stack", name)
		ui.open()

/obj/item/stack/ui_data(mob/user)
	var/list/data = list()
	data["amount"] = get_amount()
	return data

/obj/item/stack/ui_static_data(mob/user)
	var/list/data = list()
	data["recipes"] = recursively_build_recipes(recipes)
	return data

/obj/item/stack/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			if(get_amount() < 1 && !is_cyborg)
				qdel(src)
				return
			var/datum/stack_recipe/recipe = locate(params["ref"])
			if(!is_valid_recipe(recipe, recipes)) //href exploit protection
				return
			var/multiplier = text2num(params["multiplier"])
			if(!multiplier || (multiplier <= 0)) //href exploit protection
				return
			if(!building_checks(recipe, multiplier))
				return
			if(recipe.time)
				var/adjusted_time = 0
				usr.visible_message(span_notice("[usr] starts building \a [recipe.title]."), span_notice("You start building \a [recipe.title]..."))
				if(HAS_TRAIT(usr, recipe.trait_booster))
					adjusted_time = (recipe.time * recipe.trait_modifier)
				else
					adjusted_time = recipe.time
				if(!do_after(usr, time = adjusted_time, timed_action_flags = DO_PUBLIC, display = src))
					return
				if(!building_checks(recipe, multiplier))
					return

			var/obj/O
			if(recipe.max_res_amount > 1) //Is it a stack?
				O = new recipe.result_type(usr.drop_location(), recipe.res_amount * multiplier)
			else if(ispath(recipe.result_type, /turf))
				var/turf/T = usr.drop_location()
				if(!isturf(T))
					return
				T.PlaceOnTop(recipe.result_type, flags = CHANGETURF_INHERIT_AIR)
			else
				O = new recipe.result_type(usr.drop_location())
			if(O)
				O.setDir(usr.dir)
			use(recipe.req_amount * multiplier)
			usr.investigate_log("[key_name(usr)] crafted [recipe.title]", INVESTIGATE_CRAFTING)

			if(recipe.applies_mats && LAZYLEN(mats_per_unit))
				if(isstack(O))
					var/obj/item/stack/crafted_stack = O
					crafted_stack.set_mats_per_unit(mats_per_unit, recipe.req_amount / recipe.res_amount)
				else
					O.set_custom_materials(mats_per_unit, recipe.req_amount / recipe.res_amount)

			if(QDELETED(O))
				return //It's a stack and has already been merged

			O.add_fingerprint(usr) //Add fingerprints first, otherwise O might already be deleted because of stack merging
			if(isitem(O))
				usr.put_in_hands(O)

			//BubbleWrap - so newly formed boxes are empty
			if(istype(O, /obj/item/storage))
				for (var/obj/item/I in O)
					qdel(I)
			//BubbleWrap END
			return TRUE

/obj/item/stack/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, amount))
		add(clamp(vval, 1-amount, max_amount - amount)) //there must always be one.
		return TRUE
	else if(vname == NAMEOF(src, max_amount))
		max_amount = max(vval, 1)
		add((max_amount < amount) ? (max_amount - amount) : 0) //update icon, weight, ect
		return TRUE
	return ..()

/obj/item/stack/proc/building_checks(datum/stack_recipe/recipe, multiplier)
	if (get_amount() < recipe.req_amount*multiplier)
		if (recipe.req_amount*multiplier>1)
			to_chat(usr, span_warning("You haven't got enough [src] to build \the [recipe.req_amount*multiplier] [recipe.title]\s!"))
		else
			to_chat(usr, span_warning("You haven't got enough [src] to build \the [recipe.title]!"))
		return FALSE
	var/turf/dest_turf = get_turf(usr)

	// If we're making a window, we have some special snowflake window checks to do.
	if(ispath(recipe.result_type, /obj/structure/window))
		var/obj/structure/window/result_path = recipe.result_type
		if(!valid_window_location(dest_turf, usr.dir, is_fulltile = initial(result_path.fulltile)))
			to_chat(usr, span_warning("The [recipe.title] won't fit here!"))
			return FALSE

	if(recipe.one_per_turf && (locate(recipe.result_type) in dest_turf))
		to_chat(usr, span_warning("There is another [recipe.title] here!"))
		return FALSE

	if(recipe.on_tram)
		if(!locate(/obj/structure/industrial_lift/tram) in dest_turf)
			to_chat(usr, span_warning("\The [recipe.title] must be constructed on a tram floor!"))
			return FALSE

	if(recipe.on_floor)
		if(!isfloorturf(dest_turf))
			to_chat(usr, span_warning("\The [recipe.title] must be constructed on the floor!"))
			return FALSE

		for(var/obj/object in dest_turf)
			if(istype(object, /obj/structure/grille))
				continue
			if(istype(object, /obj/structure/table))
				continue
			if(istype(object, /obj/structure/window))
				var/obj/structure/window/window_structure = object
				if(!window_structure.fulltile)
					continue
			if(object.density || NO_BUILD & object.obj_flags)
				to_chat(usr, span_warning("There is \a [object.name] here. You can\'t make \a [recipe.title] here!"))
				return FALSE
	if(recipe.placement_checks)
		switch(recipe.placement_checks)
			if(STACK_CHECK_CARDINALS)
				var/turf/step
				for(var/direction in GLOB.cardinals)
					step = get_step(dest_turf, direction)
					if(locate(recipe.result_type) in step)
						to_chat(usr, span_warning("\The [recipe.title] must not be built directly adjacent to another!"))
						return FALSE
			if(STACK_CHECK_ADJACENT)
				if(locate(recipe.result_type) in range(1, dest_turf))
					to_chat(usr, span_warning("\The [recipe.title] must be constructed at least one tile away from others of its type!"))
					return FALSE
	return TRUE

/obj/item/stack/use(used, transfer = FALSE, check = TRUE) // return 0 = borked; return 1 = had enough
	if(check && is_zero_amount(delete_if_zero = TRUE))
		return FALSE

	if(is_cyborg)
		return source.use_charge(used * cost)

	if (amount < used)
		return FALSE

	amount -= used

	if(check && is_zero_amount(delete_if_zero = TRUE))
		return TRUE

	if(length(mats_per_unit))
		update_custom_materials()

	update_appearance()
	update_weight()
	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, span_warning("You need at least [amount] [singular_name]\s to do this!"))
			else
				to_chat(user, span_warning("You need at least [amount] [singular_name] to do this!"))
		else
			to_chat(user, span_warning("You need at least [amount] to do this!"))

		return FALSE

	return TRUE

/**
 * Returns TRUE if the item stack is the equivalent of a 0 amount item.
 *
 * Also deletes the item if delete_if_zero is TRUE and the stack does not have
 * is_cyborg set to true.
 */
/obj/item/stack/proc/is_zero_amount(delete_if_zero = TRUE)
	if(is_cyborg)
		return source.energy < cost
	if(amount < 1)
		if(delete_if_zero)
			qdel(src)
		return TRUE
	return FALSE

/** Adds some number of units to this stack.
 *
 * Arguments:
 * - _amount: The number of units to add to this stack.
 */
/obj/item/stack/proc/add(_amount)
	if(is_cyborg)
		source.add_charge(_amount * cost)
	else
		amount += _amount
	if(length(mats_per_unit))
		update_custom_materials()
	update_appearance()
	update_weight()

/** Checks whether this stack can merge itself into another stack.
 *
 * Arguments:
 * - [check][/obj/item/stack]: The stack to check for mergeability.
 * - [inhand][boolean]: Whether or not the stack to check should act like it's in a mob's hand.
 */
/obj/item/stack/proc/can_merge(obj/item/stack/check, inhand = FALSE)
	if(!istype(check, merge_type))
		return FALSE
	if(mats_per_unit ~! check.mats_per_unit) // ~! in case of lists this operator checks only keys, but not values
		return FALSE
	if(absorption_capacity != check.absorption_capacity)
		return FALSE
	if(is_cyborg) // No merging cyborg stacks into other stacks
		return FALSE
	if(ismob(loc) && !inhand) // no merging with items that are on the mob
		return FALSE
	return TRUE

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This calls use() without check = FALSE, preventing the item from qdeling itself if it reaches 0 stack size.
 *
 * As a result, this proc can leave behind a 0 amount stack.
 */
/obj/item/stack/proc/merge_without_del(obj/item/stack/target_stack, limit)
	// Cover edge cases where multiple stacks are being merged together and haven't been deleted properly.
	// Also cover edge case where a stack is being merged into itself, which is supposedly possible.
	if(QDELETED(target_stack))
		CRASH("Stack merge attempted on qdeleted target stack.")
	if(QDELETED(src))
		CRASH("Stack merge attempted on qdeleted source stack.")
	if(target_stack == src)
		CRASH("Stack attempted to merge into itself.")

	var/transfer = get_amount()
	if(target_stack.is_cyborg)
		transfer = min(transfer, round((target_stack.source.max_energy - target_stack.source.energy) / target_stack.cost))
	else
		transfer = min(transfer, (limit ? limit : target_stack.max_amount) - target_stack.amount)
	if(LAZYLEN(grabbed_by))
		for(var/obj/item/hand_item/grab/G in grabbed_by)
			var/mob/living/grabber = G.assailant
			qdel(G)
			grabber.try_make_grab(target_stack)

	transfer_evidence_to(target_stack)
	use(transfer, transfer = TRUE, check = FALSE)
	target_stack.add(transfer)
	if(target_stack.mats_per_unit != mats_per_unit) // We get the average value of mats_per_unit between two stacks getting merged
		var/list/temp_mats_list = list() // mats_per_unit is passed by ref into this coil, and that same ref is used in other places. If we didn't make a new list here we'd end up contaminating those other places, which leads to batshit behavior
		for(var/mat_type in target_stack.mats_per_unit)
			temp_mats_list[mat_type] = (target_stack.mats_per_unit[mat_type] * (target_stack.amount - transfer) + mats_per_unit[mat_type] * transfer) / target_stack.amount
		target_stack.mats_per_unit = temp_mats_list
	return transfer

/**
 * Merges as much of src into target_stack as possible. If present, the limit arg overrides target_stack.max_amount for transfer.
 *
 * This proc deletes src if the remaining amount after the transfer is 0.
 */
/obj/item/stack/proc/merge(obj/item/stack/target_stack, limit)
	. = merge_without_del(target_stack, limit)
	is_zero_amount(delete_if_zero = TRUE)

/// Signal handler for connect_loc element. Called when a movable enters the turf we're currently occupying. Merges if possible.
/obj/item/stack/proc/on_movable_entered_occupied_turf(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	// Edge case. This signal will also be sent when src has entered the turf. Don't want to merge with ourselves.
	if(arrived == src)
		return

	if(!arrived.throwing && can_merge(arrived))
		INVOKE_ASYNC(src, PROC_REF(merge), arrived)

/obj/item/stack/hitby(atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(can_merge(hitting, inhand = TRUE))
		merge(hitting)
	. = ..()

/obj/item/stack/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	if(splint_slowdown)
		return try_splint(interacting_with, user)

	if(!absorption_capacity || !ishuman(interacting_with))
		return NONE

	var/mob/living/carbon/human/target = interacting_with
	var/obj/item/bodypart/BP = target.get_bodypart(user.zone_selected, TRUE)
	if(BP.bandage)
		to_chat(user, span_warning("[target]'s [BP.plaintext_zone] is already bandaged."))
		return ITEM_INTERACT_BLOCKING

	if(!do_after(user, target, 5 SECONDS, DO_PUBLIC, display = src))
		return ITEM_INTERACT_BLOCKING

	if(user == target)
		user.visible_message(span_notice("[user] applies [src] to [user.p_their()] [BP.plaintext_zone]."))
	else
		user.visible_message(span_notice("[user] applies [src] to [target]'s [BP.plaintext_zone]."))
	BP.apply_bandage(src)
	return ITEM_INTERACT_SUCCESS

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		return split_stack(user, 1, user)
	else
		. = ..()

/obj/item/stack/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(is_cyborg || !user.canUseTopic(src, USE_CLOSE|USE_DEXTERITY))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	if(is_zero_amount(delete_if_zero = TRUE))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/max = get_amount()
	var/stackmaterial = tgui_input_number(user, "How many sheets do you wish to take out of this stack?", "Stack Split", max_value = max)
	if(!stackmaterial || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, USE_CLOSE|USE_DEXTERITY))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	split_stack(user, stackmaterial, user)
	to_chat(user, span_notice("You take [stackmaterial] [singular_name || "sheets"] out of the [stack_name]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/** Splits the stack into two stacks.
 *
 * Arguments:
 * - [user][/mob]: The mob splitting the stack.
 * - amount: The number of units to split from this stack.
 * - spawn_loc: The place to spawn the new stack, accepts null.
 */
/obj/item/stack/proc/split_stack(mob/user, amount, spawn_loc)
	if(!use(amount, TRUE, FALSE))
		return null

	var/obj/item/stack/F = new type(spawn_loc, amount, FALSE, mats_per_unit, null, absorption_capacity)
	. = F
	transfer_evidence_to(F)
	loc.atom_storage?.refresh_views()
	if(user)
		if(!user.put_in_hands(F, merge_stacks = FALSE))
			F.forceMove(user.drop_location())
		add_fingerprint(user)
		F.add_fingerprint(user)

	is_zero_amount(delete_if_zero = TRUE)

/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(can_merge(W, inhand = TRUE))
		var/obj/item/stack/S = W
		if(merge(S))
			to_chat(user, span_notice("[S] [stack_name] of [S.name] now contains [S.get_amount()] [S.singular_name]\s."))
	else
		. = ..()

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(istype(M) && M.dirty < 100)
		M.dirty += amount

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = FALSE
	var/on_floor = FALSE
	var/on_tram = FALSE
	var/placement_checks = FALSE
	var/applies_mats = FALSE
	var/trait_booster = null
	var/trait_modifier = 1

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1,time = 0, one_per_turf = FALSE, on_floor = FALSE, on_tram = FALSE, window_checks = FALSE, placement_checks = FALSE, applies_mats = FALSE, trait_booster = null, trait_modifier = 1)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.on_tram = on_tram
	src.placement_checks = placement_checks
	src.applies_mats = applies_mats
	src.trait_booster = trait_booster
	src.trait_modifier = trait_modifier
/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes

#undef STACK_CHECK_CARDINALS
#undef STACK_CHECK_ADJACENT
