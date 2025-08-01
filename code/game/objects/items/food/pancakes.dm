#define PANCAKE_MAX_STACK 10

/obj/item/food/pancakes
	name = "pancake"
	desc = "A fluffy pancake. The softer, superior relative of the waffle."
	icon_state = "pancakes_1"
	inhand_icon_state = "pancakes"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pancakes" = 1)
	foodtypes = GRAIN | SUGAR | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/pancakes/raw
	name = "goopy pancake"
	desc = "A barely cooked mess that some may mistake for a pancake. It longs for the griddle."
	icon_state = "rawpancakes_1"
	inhand_icon_state = "rawpancakes"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("milky batter" = 1)
	burns_on_grill = FALSE

/obj/item/food/pancakes/raw/MakeGrillable()
	AddComponent(/datum/component/grillable,\
				cook_result = /obj/item/food/pancakes,\
				required_cook_time = rand(30 SECONDS, 40 SECONDS),\
				positive_result = TRUE,\
				use_large_steam_sprite = TRUE)

/obj/item/food/pancakes/raw/attackby(obj/item/garnish, mob/living/user, params)
	var/newresult
	if(istype(garnish, /obj/item/food/grown/berries))
		newresult = /obj/item/food/pancakes/blueberry
		name = "raw blueberry pancake"
		icon_state = "rawbbpancakes_1"
		inhand_icon_state = "rawbbpancakes"
	else if(istype(garnish, /obj/item/food/chocolatebar))
		newresult = /obj/item/food/pancakes/chocolatechip
		name = "raw chocolate chip pancake"
		icon_state = "rawccpancakes_1"
		inhand_icon_state = "rawccpancakes"
	else
		return ..()
	if(newresult)
		qdel(garnish)
		to_chat(user, span_notice("You add [garnish] to [src]."))
		AddComponent(/datum/component/grillable, cook_result = newresult)

/obj/item/food/pancakes/raw/examine(mob/user)
	. = ..()
	if(name == initial(name))
		. += "<span class='notice'>You can modify the pancake by adding <b>blueberries</b> or <b>chocolate</b> before finishing the griddle."

/obj/item/food/pancakes/blueberry
	name = "blueberry pancake"
	desc = "A fluffy and delicious blueberry pancake."
	icon_state = "bbpancakes_1"
	inhand_icon_state = "bbpancakes"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pancakes" = 1, "blueberries" = 1)

/obj/item/food/pancakes/chocolatechip
	name = "chocolate chip pancake"
	desc = "A fluffy and delicious chocolate chip pancake."
	icon_state = "ccpancakes_1"
	inhand_icon_state = "ccpancakes"
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pancakes" = 1, "chocolate" = 1)

/obj/item/food/pancakes/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/food/pancakes/update_name()
	name = contents.len ? "stack of pancakes" : initial(name)
	return ..()

/obj/item/food/pancakes/update_icon(updates = ALL)
	if(!(updates & UPDATE_OVERLAYS))
		return ..()

	updates &= ~UPDATE_OVERLAYS
	. = ..() // Don't update overlays. We're doing that here

	if(contents.len < LAZYLEN(overlays))
		overlays -= overlays[overlays.len]
	. |= UPDATE_OVERLAYS

/obj/item/food/pancakes/examine(mob/user)
	var/ingredients_listed = ""
	var/pancakeCount = contents.len
	switch(pancakeCount)
		if(0)
			desc = initial(desc)
		if(1 to 2)
			desc = "A stack of fluffy pancakes."
		if(3 to 6)
			desc = "A fat stack of fluffy pancakes!"
		if(7 to 9)
			desc = "A grand tower of fluffy, delicious pancakes!"
		if(PANCAKE_MAX_STACK to INFINITY)
			desc = "A massive towering spire of fluffy, delicious pancakes. It looks like it could tumble over!"
	. = ..()
	if (pancakeCount)
		for(var/obj/item/food/pancakes/ING in contents)
			ingredients_listed += "[ING.name], "
		. += "It contains [contents.len?"[ingredients_listed]":"no ingredient, "]on top of a [initial(name)]."

/obj/item/food/pancakes/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/food/pancakes))
		var/obj/item/food/pancakes/pancake = item
		if((contents.len >= PANCAKE_MAX_STACK) || ((pancake.contents.len + contents.len) > PANCAKE_MAX_STACK))
			to_chat(user, span_warning("You can't add that many pancakes to [src]!"))
		else
			if(!user.transferItemToLoc(pancake, src))
				return
			to_chat(user, span_notice("You add the [pancake] to the [src]."))
			pancake.name = initial(pancake.name)
			contents += pancake
			update_snack_overlays(pancake)
			if (pancake.contents.len)
				for(var/pancake_content in pancake.contents)
					pancake = pancake_content
					pancake.name = initial(pancake.name)
					contents += pancake
					update_snack_overlays(pancake)
			pancake = item
			pancake.contents.Cut()
		return
	else if(contents.len)
		var/obj/O = contents[contents.len]
		return O.attackby(item, user, params)
	..()

/obj/item/food/pancakes/proc/update_snack_overlays(obj/item/pancake)
	var/mutable_appearance/pancake_visual = mutable_appearance(icon, "[pancake.inhand_icon_state]_[rand(1, 3)]")
	pancake_visual.pixel_x = rand(-1, 1)
	pancake_visual.pixel_y = 3 * contents.len - 1
	add_overlay(pancake_visual)
	update_appearance()

/obj/item/food/pancakes/get_attacking_item(mob/living/user, atom/target)
	if(!user.combat_mode && contents.len)
		return contents[contents.len]
	return ..()

#undef PANCAKE_MAX_STACK
