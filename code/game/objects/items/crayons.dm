#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_PUNCTUATION "Random Punctuation"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_SYMBOL "Random Symbol"
#define RANDOM_DRAWING "Random Drawing"
#define RANDOM_ORIENTED "Random Oriented"
#define RANDOM_RUNE "Random Rune"
#define RANDOM_ANY "Random Anything"

#define PAINT_NORMAL 1
#define PAINT_LARGE_HORIZONTAL 2
#define PAINT_LARGE_HORIZONTAL_ICON 'icons/effects/96x32.dmi'

#define AVAILABLE_SPRAYCAN_SPACE 8 // enough to fill one radial menu page

/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "red crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	worn_icon_state = "crayon"

	var/icon_capped
	var/icon_uncapped
	var/use_overlays = FALSE

	var/crayon_color = "red"
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("attacks", "colours")
	attack_verb_simple = list("attack", "colour")
	grind_results = list()
	var/paint_color = "#FF0000" //RGB

	var/drawtype
	var/text_buffer = ""

	var/static/list/graffiti = list("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","body","cyka","star","poseur tag","prolizard","antilizard")
	var/static/list/symbols = list("danger","firedanger","electricdanger","biohazard","radiation","safe","evac","space","med","trade","shop","food","peace","like","skull","nay","heart","credit")
	var/static/list/drawings = list("smallbrush","brush","largebrush","splatter","snake","stickman","carp","ghost","clown","taser","disk","fireaxe","toolbox","corgi","cat","toilet","blueprint","beepsky","scroll","bottle","shotgun")
	var/static/list/oriented = list("arrow","line","thinline","shortline","body","chevron","footprint","clawprint","pawprint") // These turn to face the same way as the drawer
	var/static/list/runes = list("rune1","rune2","rune3","rune4","rune5","rune6")
	var/static/list/randoms = list(RANDOM_ANY, RANDOM_RUNE, RANDOM_ORIENTED,
		RANDOM_NUMBER, RANDOM_GRAFFITI, RANDOM_LETTER, RANDOM_SYMBOL, RANDOM_PUNCTUATION, RANDOM_DRAWING)
	var/static/list/graffiti_large_h = list("yiffhell", "secborg", "paint")

	var/static/list/all_drawables = graffiti + symbols + drawings + oriented + runes + graffiti_large_h

	var/paint_mode = PAINT_NORMAL

	var/charges = 30 //-1 or less for unlimited uses
	var/charges_left
	var/volume_multiplier = 1 // Increases reagent effect

	var/actually_paints = TRUE

	var/instant = FALSE
	var/self_contained = TRUE // If it deletes itself when it is empty

	var/edible = TRUE // That doesn't mean eating it is a good idea

	var/list/reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5)
	// If the user can toggle the colour, a la vanilla spraycan
	var/can_change_colour = FALSE

	var/has_cap = FALSE
	var/is_capped = FALSE

	var/pre_noise = FALSE
	var/post_noise = FALSE

/obj/item/toy/crayon/proc/isValidSurface(surface)
	return istype(surface, /turf/open/floor)

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is jamming [src] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide!"))
	user.add_atom_colour(paint_color)
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/Initialize(mapload)
	. = ..()

	dye_color = crayon_color

	drawtype = pick(all_drawables)

	AddElement(/datum/element/venue_price, FOOD_PRICE_EXOTIC)
	if(can_change_colour)
		AddComponent(/datum/component/palette, AVAILABLE_SPRAYCAN_SPACE, paint_color)

	refill()

	if(edible)
		AddComponent(/datum/component/edible, bite_consumption = reagents.total_volume / (charges_left / 5), after_eat = CALLBACK(src, PROC_REF(after_eat)), initial_reagents = reagent_contents)

/// Used for edible component to reduce charges_left on bite.
/obj/item/toy/crayon/proc/after_eat(mob/user)
	use_charges(user, amount = 5, requires_full = FALSE)
	if(check_empty(user)) //Prevents division by zero
		return

/obj/item/toy/crayon/set_painting_tool_color(chosen_color)
	. = ..()
	paint_color = chosen_color
	update_appearance()

/obj/item/toy/crayon/proc/refill()
	if(charges == -1)
		charges_left = 100
	else
		charges_left = charges

	if(!reagents)
		create_reagents(charges_left * volume_multiplier)
	reagents.clear_reagents()

	var/total_weight = 0
	for(var/key in reagent_contents)
		total_weight += reagent_contents[key]

	var/units_per_weight = reagents.maximum_volume / total_weight
	for(var/reagent in reagent_contents)
		var/weight = reagent_contents[reagent]
		var/amount = weight * units_per_weight
		reagents.add_reagent(reagent, amount)

/obj/item/toy/crayon/proc/use_charges(mob/user, amount = 1, requires_full = TRUE)
	// Returns number of charges actually used
	if(charges == -1)
		. = amount
		refill()
	else
		if(check_empty(user, amount, requires_full))
			return 0
		else
			. = min(charges_left, amount)
			charges_left -= .

/obj/item/toy/crayon/proc/check_empty(mob/user, amount = 1, requires_full = TRUE)
	// When eating a crayon, check_empty() can be called twice producing
	// two messages unless we check for being deleted first
	if(QDELETED(src))
		return TRUE

	. = FALSE
	// -1 is unlimited charges
	if(charges == -1)
		. = FALSE
	else if(!charges_left)
		to_chat(user, span_warning("There is no more of [src] left!"))
		if(self_contained)
			qdel(src)
		. = TRUE
	else if(charges_left < amount && requires_full)
		to_chat(user, span_warning("There is not enough of [src] left!"))
		. = TRUE

/obj/item/toy/crayon/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/toy/crayon/ui_interact(mob/user, datum/tgui/ui)
	// tgui is a plague upon this codebase
	// no u
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Crayon", name)
		ui.open()

/obj/item/toy/crayon/spraycan/AltClick(mob/user)
	if(has_cap && user.canUseTopic(src, USE_CLOSE|USE_NEED_HANDS))
		is_capped = !is_capped
		to_chat(user, span_notice("The cap on [src] is now [is_capped ? "on" : "off"]."))
		update_appearance()

/obj/item/toy/crayon/proc/staticDrawables()

	. = list()

	var/list/g_items = list()
	. += list(list("name" = "Graffiti", "items" = g_items))
	for(var/g in graffiti)
		g_items += list(list("item" = g))

	var/list/glh_items = list()
	. += list(list("name" = "Graffiti Large Horizontal", "items" = glh_items))
	for(var/glh in graffiti_large_h)
		glh_items += list(list("item" = glh))

	var/list/S_items = list()
	. += list(list("name" = "Symbols", "items" = S_items))
	for(var/S in symbols)
		S_items += list(list("item" = S))

	var/list/D_items = list()
	. += list(list("name" = "Drawings", "items" = D_items))
	for(var/D in drawings)
		D_items += list(list("item" = D))

	var/list/O_items = list()
	. += list(list(name = "Oriented", "items" = O_items))
	for(var/O in oriented)
		O_items += list(list("item" = O))

	var/list/R_items = list()
	. += list(list(name = "Runes", "items" = R_items))
	for(var/R in runes)
		R_items += list(list("item" = R))

	var/list/rand_items = list()
	. += list(list(name = "Random", "items" = rand_items))
	for(var/i in randoms)
		rand_items += list(list("item" = i))


/obj/item/toy/crayon/ui_data()

	var/static/list/crayon_drawables

	if (!crayon_drawables)
		crayon_drawables = staticDrawables()

	. = list()
	.["drawables"] = crayon_drawables
	.["selected_stencil"] = drawtype
	.["text_buffer"] = text_buffer

	.["has_cap"] = has_cap
	.["is_capped"] = is_capped
	.["can_change_colour"] = can_change_colour
	.["current_colour"] = paint_color

/obj/item/toy/crayon/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_cap")
			if(has_cap)
				is_capped = !is_capped
				. = TRUE
		if("select_stencil")
			var/stencil = params["item"]
			if(stencil in (all_drawables + randoms))
				drawtype = stencil
				. = TRUE
				text_buffer = ""
			if(stencil in graffiti_large_h)
				paint_mode = PAINT_LARGE_HORIZONTAL
				text_buffer = ""
			else
				paint_mode = PAINT_NORMAL
		if("select_colour")
			. = can_change_colour && pick_painting_tool_color(usr, paint_color)
		if("enter_text")
			var/txt = tgui_input_text(usr, "Choose what to write", "Scribbles", text_buffer)
			if(isnull(txt))
				return
			txt = crayon_text_strip(txt)
			if(text_buffer == txt)
				return // No valid changes.
			text_buffer = txt

			. = TRUE
			paint_mode = PAINT_NORMAL
			drawtype = "a"
	update_appearance()

/obj/item/toy/crayon/proc/crayon_text_strip(text)
	text = copytext(text, 1, MAX_MESSAGE_LEN)
	var/static/regex/crayon_regex = new /regex(@"[^\w!?,.=&%#+/\-]", "ig")
	return lowertext(crayon_regex.Replace(text, ""))

/obj/item/toy/crayon/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!check_allowed_items(interacting_with))
		return NONE

	if(can_use_on(interacting_with, user, modifiers))
		return use_on(interacting_with, user, modifiers)
	return NONE

/// Is this a valid object for use_on to run on?
/obj/item/toy/crayon/proc/can_use_on(atom/target, mob/user, list/modifiers)
	if(!isturf(target) && !istype(target, /obj/effect/decal/cleanable))
		return FALSE
	return TRUE

/obj/item/toy/crayon/proc/use_on(atom/target, mob/user, list/modifiers)
	if(istype(target, /obj/effect/decal/cleanable))
		target = target.loc

	if(!isValidSurface(target))
		return NONE

	var/static/list/punctuation = list("!","?",".",",","/","+","-","=","%","#","&")

	var/drawing = drawtype
	switch(drawtype)
		if(RANDOM_LETTER)
			drawing = ascii2text(rand(97, 122)) // a-z
		if(RANDOM_PUNCTUATION)
			drawing = pick(punctuation)
		if(RANDOM_SYMBOL)
			drawing = pick(symbols)
		if(RANDOM_DRAWING)
			drawing = pick(drawings)
		if(RANDOM_GRAFFITI)
			drawing = pick(graffiti)
		if(RANDOM_RUNE)
			drawing = pick(runes)
		if(RANDOM_ORIENTED)
			drawing = pick(oriented)
		if(RANDOM_NUMBER)
			drawing = ascii2text(rand(48, 57)) // 0-9
		if(RANDOM_ANY)
			drawing = pick(all_drawables)

	var/istagger = HAS_TRAIT(user, TRAIT_TAGGER)

	var/cost = 1
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		cost = 5
	if(istype(target, /obj/item/canvas))
		cost = 0
	if(ishuman(user))
		if (istagger)
			cost *= 0.5

	if(check_empty(user, cost))
		return ITEM_INTERACT_BLOCKING

	var/temp = "rune"
	var/ascii = (length(drawing) == 1)
	if(ascii && is_alpha(drawing))
		temp = "letter"
	else if(ascii && is_digit(drawing))
		temp = "number"
	else if(drawing in punctuation)
		temp = "punctuation mark"
	else if(drawing in symbols)
		temp = "symbol"
	else if(drawing in drawings)
		temp = "drawing"
	else if(drawing in (graffiti|oriented))
		temp = "graffiti"

	var/gang_mode
	if(user.mind)
		gang_mode = user.mind.has_antag_datum(/datum/antagonist/gang)

	if(gang_mode && (!can_claim_for_gang(user, target, gang_mode)))
		return ITEM_INTERACT_BLOCKING


	var/graf_rot
	if(drawing in oriented)
		switch(user.dir)
			if(EAST)
				graf_rot = 90
			if(SOUTH)
				graf_rot = 180
			if(WEST)
				graf_rot = 270
			else
				graf_rot = 0

	var/clickx
	var/clicky

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		clickx = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
		clicky = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)

	if(!instant)
		to_chat(user, span_notice("You start drawing a [temp] on the [target.name]..."))

	if(pre_noise)
		audible_message(span_notice("You hear spraying."))
		playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

	var/wait_time = 50
	if(paint_mode == PAINT_LARGE_HORIZONTAL)
		wait_time *= 3

	if(gang_mode || !instant)
		if(!do_after(user, target, 5 SECONDS, DO_PUBLIC, display = src))
			return ITEM_INTERACT_BLOCKING

	var/charges_used = use_charges(user, cost)
	if(!charges_used)
		return ITEM_INTERACT_BLOCKING

	. = ITEM_INTERACT_SUCCESS

	if(length(text_buffer))
		drawing = text_buffer[1]


	var/list/turf/affected_turfs = list()

	if(actually_paints)
		var/obj/effect/decal/cleanable/crayon/C
		if(gang_mode)
			if(!can_claim_for_gang(user, target))
				return ITEM_INTERACT_BLOCKING

			tag_for_gang(user, target, gang_mode)
			affected_turfs += target

		else
			switch(paint_mode)
				if(PAINT_NORMAL)
					C = new(target, null, null, paint_color, drawing, temp, graf_rot)
					C.pixel_x = clickx
					C.pixel_y = clicky
					affected_turfs += target

				if(PAINT_LARGE_HORIZONTAL)
					var/turf/left = locate(target.x-1,target.y,target.z)
					var/turf/right = locate(target.x+1,target.y,target.z)
					if(isValidSurface(left) && isValidSurface(right))
						C = new(left, paint_color, drawing, temp, graf_rot, PAINT_LARGE_HORIZONTAL_ICON)
						affected_turfs += left
						affected_turfs += right
						affected_turfs += target
					else
						to_chat(user, span_warning("There isn't enough space to paint!"))
						return ITEM_INTERACT_BLOCKING

			C.log_touch(user)
			if(istagger)
				C.AddElement(/datum/element/art, GOOD_ART)
			else
				C.AddElement(/datum/element/art, BAD_ART)

	if(!instant)
		to_chat(user, span_notice("You finish drawing \the [temp]."))
	else
		to_chat(user, span_notice("You spray a [temp] on \the [target.name]"))

	if(length(text_buffer) > 1)
		text_buffer = copytext(text_buffer, length(text_buffer[1]) + 1)
		SStgui.update_uis(src)

	if(post_noise)
		audible_message(span_hear("You hear spraying."))
		playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

	var/fraction = min(1, . / reagents.maximum_volume)
	if(affected_turfs.len)
		fraction /= affected_turfs.len

	for(var/t in affected_turfs)
		reagents.trans_to(t, ., volume_multiplier, transfered_by = user, methods = TOUCH)

	check_empty(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/toy/crayon/proc/can_claim_for_gang(mob/user, atom/target, datum/antagonist/gang/user_gang)
	var/area/A = get_area(target)
	if(!A || (!is_station_level(A.z)))
		to_chat(user, span_warning("[A] is unsuitable for tagging."))
		return FALSE

	var/spraying_over = FALSE
	for(var/obj/effect/decal/cleanable/crayon/gang/G in target)
		spraying_over = TRUE

	for(var/obj/machinery/power/apc in target)
		to_chat(user, span_warning("You can't tag an APC."))
		return FALSE

	var/obj/effect/decal/cleanable/crayon/gang/occupying_gang = territory_claimed(A, user)
	if(occupying_gang && !spraying_over)
		if(occupying_gang.my_gang == user_gang.my_gang)
			to_chat(user, span_danger("[A] has already been tagged by our gang!"))
		else
			to_chat(user, span_danger("[A] has already been tagged by a gang! You must find and spray over the old tag instead!"))
		return FALSE

	// stolen from oldgang lmao
	return TRUE

/obj/item/toy/crayon/proc/tag_for_gang(mob/user, atom/target, datum/antagonist/gang/user_gang)
	for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
		qdel(old_marking)

	var/area/territory = get_area(target)

	var/obj/effect/decal/cleanable/crayon/gang/tag = new /obj/effect/decal/cleanable/crayon/gang(target)
	tag.my_gang = user_gang.my_gang
	tag.icon_state = "[user_gang.gang_id]_tag"
	tag.name = "[tag.my_gang.name] gang tag"
	tag.desc = "Looks like someone's claimed this area for [tag.my_gang.name]."
	to_chat(user, span_notice("You tagged [territory] for [tag.my_gang.name]!"))

/obj/item/toy/crayon/proc/territory_claimed(area/territory, mob/user)
	for(var/obj/effect/decal/cleanable/crayon/gang/G in GLOB.gang_tags)
		if(get_area(G) == territory)
			return G

/obj/item/toy/crayon/red
	name = "red crayon"
	icon_state = "crayonred"
	paint_color = "#DA0000"
	crayon_color = "red"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/red/crayon = 1.5)
	dye_color = DYE_RED

/obj/item/toy/crayon/orange
	name = "orange crayon"
	icon_state = "crayonorange"
	paint_color = "#FF9300"
	crayon_color = "orange"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/orange/crayon = 1.5)
	dye_color = DYE_ORANGE

/obj/item/toy/crayon/yellow
	name = "yellow crayon"
	icon_state = "crayonyellow"
	paint_color = "#FFF200"
	crayon_color = "yellow"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/yellow/crayon = 1.5)
	dye_color = DYE_YELLOW

/obj/item/toy/crayon/green
	name = "green crayon"
	icon_state = "crayongreen"
	paint_color = "#A8E61D"
	crayon_color = "green"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/green/crayon = 1.5)
	dye_color = DYE_GREEN

/obj/item/toy/crayon/blue
	name = "blue crayon"
	icon_state = "crayonblue"
	paint_color = "#00B7EF"
	crayon_color = "blue"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/blue/crayon = 1.5)
	dye_color = DYE_BLUE

/obj/item/toy/crayon/purple
	name = "purple crayon"
	icon_state = "crayonpurple"
	paint_color = "#DA00FF"
	crayon_color = "purple"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/purple/crayon = 1.5)
	dye_color = DYE_PURPLE

/obj/item/toy/crayon/black
	name = "black crayon"
	icon_state = "crayonblack"
	paint_color = "#1C1C1C" //Not completely black because total black looks bad. So Mostly Black.
	crayon_color = "black"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/black/crayon = 1.5)
	dye_color = DYE_BLACK

/obj/item/toy/crayon/white
	name = "white crayon"
	icon_state = "crayonwhite"
	paint_color = "#FFFFFF"
	crayon_color = "white"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5,  /datum/reagent/colorful_reagent/powder/white/crayon = 1.5)
	dye_color = DYE_WHITE

/obj/item/toy/crayon/mime
	name = "mime crayon"
	icon_state = "crayonmime"
	desc = "A very sad-looking crayon."
	paint_color = "#FFFFFF"
	crayon_color = "mime"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent/powder/invisible = 1.5)
	charges = -1
	dye_color = DYE_MIME

/obj/item/toy/crayon/rainbow
	name = "rainbow crayon"
	icon_state = "crayonrainbow"
	paint_color = "#FFF000"
	crayon_color = "rainbow"
	reagent_contents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/colorful_reagent = 1.5)
	drawtype = RANDOM_ANY // just the default starter.
	charges = -1
	dye_color = DYE_RAINBOW

/obj/item/toy/crayon/rainbow/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	set_painting_tool_color(rgb(rand(0,255), rand(0,255), rand(0,255)))
	return ..()

/*
 * Crayon Box
 */

TYPEINFO_DEF(/obj/item/storage/crayons)
	default_materials = list(/datum/material/cardboard = 2000)

/obj/item/storage/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/crayons/Initialize(mapload)
	. = ..()
	create_storage(canhold = list(/obj/item/toy/crayon))

/obj/item/storage/crayons/PopulateContents()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	new /obj/item/toy/crayon/black(src)
	update_appearance()

/obj/item/storage/crayons/update_overlays()
	. = ..()
	for(var/obj/item/toy/crayon/crayon in contents)
		. += mutable_appearance('icons/obj/crayons.dmi', crayon.crayon_color)

/obj/item/storage/crayons/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		switch(C.crayon_color)
			if("mime")
				to_chat(usr, span_warning("This crayon is too sad to be contained in this box!"))
				return
			if("rainbow")
				to_chat(usr, span_warning("This crayon is too powerful to be contained in this box!"))
				return
		if(istype(W, /obj/item/toy/crayon/spraycan))
			to_chat(user, span_warning("Spraycans are not crayons!"))
			return
	return ..()

/obj/item/storage/crayons/attack_self(mob/user)
	. = ..()
	if(contents.len > 0)
		to_chat(user, span_warning("You can't fold down [src] with crayons inside!"))
		return
	if(flags_1 & HOLOGRAM_1)
		return

	var/obj/item/stack/sheet/cardboard/cardboard = new /obj/item/stack/sheet/cardboard(user.drop_location())
	to_chat(user, span_notice("You fold the [src] into cardboard."))
	user.put_in_active_hand(cardboard)
	qdel(src)

//Spraycan stuff

/obj/item/toy/crayon/spraycan
	name = "spray can"
	icon_state = "spraycan"
	worn_icon_state = "spraycan"

	icon_capped = "spraycan_cap"
	icon_uncapped = "spraycan"
	use_overlays = TRUE
	paint_color = null

	inhand_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	desc = "A metallic container containing tasty paint."

	instant = TRUE
	edible = FALSE
	has_cap = TRUE
	is_capped = TRUE
	self_contained = FALSE // Don't disappear when they're empty
	can_change_colour = TRUE

	reagent_contents = list(/datum/reagent/fuel = 1, /datum/reagent/consumable/ethanol = 1)

	pre_noise = TRUE
	post_noise = FALSE

/obj/item/toy/crayon/spraycan/isValidSurface(surface)
	return (istype(surface, /turf/open/floor) || istype(surface, /turf/closed/wall))


/obj/item/toy/crayon/spraycan/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	if(is_capped || !actually_paints)
		user.visible_message(span_suicide("[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, but nothing happens!"))
		user.say("MEDIOCRE!!", forced="spraycan suicide")
		return SHAME
	else
		user.visible_message(span_suicide("[user] shakes up [src] with a rattle and lifts it to [user.p_their()] mouth, spraying paint across [user.p_their()] teeth!"))
		user.say("WITNESS ME!!", forced="spraycan suicide")
		if(pre_noise || post_noise)
			playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
		if(can_change_colour)
			set_painting_tool_color("#C0C0C0")
		update_appearance()
		if(actually_paints)
			H.update_lips("spray_face", paint_color)
		var/used = use_charges(user, 10, FALSE)
		reagents.trans_to(user, used, volume_multiplier, transfered_by = user, methods = VAPOR)

		return (OXYLOSS)

/obj/item/toy/crayon/spraycan/Initialize(mapload)
	. = ..()
	// If default crayon red colour, pick a more fun spraycan colour
	if(!paint_color)
		set_painting_tool_color(pick("#DA0000", "#FF9300", "#FFF200", "#A8E61D", "#00B7EF", "#DA00FF"))
	refill()

/obj/item/toy/crayon/spraycan/examine(mob/user)
	. = ..()
	if(charges_left)
		. += "It has [charges_left] use\s left."
	else
		. += "It is empty."
	. += span_notice("Alt-click [src] to [ is_capped ? "take the cap off" : "put the cap on"]. Right-click a colored object to match its existing color.")

/obj/item/toy/crayon/spraycan/can_use_on(atom/target, mob/user, list/modifiers)
	if(iscarbon(target))
		return TRUE
	if(is_capped && ATOM_HAS_FIRST_CLASS_INTERACTION(target))
		// specifically don't try to use a capped spraycan on stuff like bags and tables, just place it
		return FALSE
	if(ismob(target) && HAS_TRAIT(target, TRAIT_SPRAY_PAINTABLE))
		return TRUE
	if(isobj(target) && !(target.flags_1 & UNPAINTABLE_1))
		return TRUE
	return ..()

/obj/item/toy/crayon/spraycan/use_on(atom/target, mob/user, list/modifiers)
	if(is_capped)
		to_chat(user, span_warning("There is a cap on [src]."))
		return ITEM_INTERACT_BLOCKING

	if(check_empty(user))
		return ITEM_INTERACT_BLOCKING

	if(iscarbon(target))
		if(pre_noise || post_noise)
			playsound(user.loc, 'sound/effects/spray.ogg', 25, TRUE, 5)

		var/mob/living/carbon/C = target
		user.visible_message(span_danger("[user] sprays [src] into the face of [target]!"))
		to_chat(target, span_userdanger("[user] sprays [src] into your face!"))

		if(C.client)
			C.blur_eyes(3)
			C.blind_eyes(1)

		if(C.get_eye_protection() <= 0) // no eye protection? ARGH IT BURNS. Warning: don't add a stun here. It's a roundstart item with some quirks.
			C.apply_effects(eyeblur = 5, jitter = 10)
			flash_color(C, flash_color=paint_color, flash_time=40)

		if(ishuman(C) && actually_paints)
			var/mob/living/carbon/human/H = C
			H.update_lips("spray_face", paint_color)

		use_charges(user, 10, FALSE)

		var/fraction = min(1, . / reagents.maximum_volume)
		reagents.expose(C, VAPOR, fraction * volume_multiplier)

	if(ismob(target) && (HAS_TRAIT(target, TRAIT_SPRAY_PAINTABLE)))
		if(actually_paints)
			target.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
			SEND_SIGNAL(target, COMSIG_LIVING_MOB_PAINTED)

		use_charges(user, 2, requires_full = FALSE)
		reagents.trans_to(target, ., volume_multiplier, transfered_by = user, methods = VAPOR)

		if(pre_noise || post_noise)
			playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)
		user.visible_message(span_notice("[user] coats [target] with spray paint!"), span_notice("You coat [target] with spray paint."))
		return ITEM_INTERACT_SUCCESS


	if(!isobj(target) || (target.flags_1 & UNPAINTABLE_1))
		return ..()

	if(actually_paints)
		var/color_is_dark = is_color_dark(paint_color)

		if (color_is_dark && !(target.flags_1 & ALLOW_DARK_PAINTS_1))
			to_chat(user, span_warning("A color that dark on an object like this? Surely not..."))
			return ITEM_INTERACT_BLOCKING

		target.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
		if(isitem(target) && isliving(target.loc))
			var/obj/item/target_item = target
			var/mob/living/holder = target.loc
			if(holder.is_holding(target_item))
				holder.update_held_items()
			else
				holder.update_clothing(target_item.slot_flags)

		SEND_SIGNAL(target, COMSIG_OBJ_PAINTED, color_is_dark)

	use_charges(user, 2, requires_full = FALSE)
	reagents.trans_to(target, ., volume_multiplier, transfered_by = user, methods = VAPOR)

	if(pre_noise || post_noise)
		playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

	user.visible_message(span_notice("[user] coats [target] with spray paint."), span_notice("You coat [target] with spray paint."))
	return ITEM_INTERACT_SUCCESS


/obj/item/toy/crayon/spraycan/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(is_capped)
		to_chat(user, span_warning("The cap is on."))
		return ITEM_INTERACT_BLOCKING

	if(check_empty(user))
		return ITEM_INTERACT_BLOCKING

	if(istype(interacting_with, /obj/item/bodypart) && actually_paints)

		var/obj/item/bodypart/limb = interacting_with
		if(!(limb.bodytype & BODYTYPE_HUMANOID))
			to_chat(user, span_notice("You can't think of anything to change about [src]."))
			return ITEM_INTERACT_BLOCKING

		if(!IS_ORGANIC_LIMB(limb))
			var/list/skins = list()
			var/static/list/style_list_icons = list(
				"standard" = 'icons/mob/augmentation/augments.dmi',
				"engineer" = 'icons/mob/augmentation/augments_engineer.dmi',
				"security" = 'icons/mob/augmentation/augments_security.dmi',
				"mining" = 'icons/mob/augmentation/augments_mining.dmi'
			)

			for(var/skin_option in style_list_icons)
				var/image/part_image = image(icon = style_list_icons[skin_option], icon_state = "[limb.limb_id]_[limb.body_zone]")
				if(limb.aux_zone) //Hands
					part_image.overlays += image(icon = style_list_icons[skin_option], icon_state = "[limb.limb_id]_[limb.aux_zone]")
				skins += list("[skin_option]" = part_image)

			var/choice = show_radial_menu(user, src, skins, require_near = TRUE)

			if(choice && (use_charges(user, 5, requires_full = FALSE) == 5))
				playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)
				limb.change_appearance(style_list_icons[choice], greyscale = FALSE)
			return ITEM_INTERACT_SUCCESS

	if(interacting_with.color)
		paint_color = interacting_with.color
		to_chat(user, span_notice("You adjust the color of [src] to match [interacting_with]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	else
		to_chat(user, span_warning("[interacting_with] is not colorful enough, you can't match that color."))

	return ITEM_INTERACT_BLOCKING

/obj/item/toy/crayon/spraycan/update_icon_state()
	icon_state = is_capped ? icon_capped : icon_uncapped
	return ..()

/obj/item/toy/crayon/spraycan/update_overlays()
	. = ..()
	if(use_overlays)
		var/mutable_appearance/spray_overlay = mutable_appearance('icons/obj/crayons.dmi', "[is_capped ? "spraycan_cap_colors" : "spraycan_colors"]")
		spray_overlay.color = paint_color
		. += spray_overlay

/obj/item/toy/crayon/spraycan/borg
	name = "cyborg spraycan"
	desc = "A metallic container containing shiny synthesised paint."
	charges = -1

/obj/item/toy/crayon/spraycan/borg/afterattack(atom/target,mob/user,proximity, params)
	var/diff = ..()
	if(!iscyborg(user))
		to_chat(user, span_notice("How did you get this?"))
		qdel(src)
		return FALSE

	var/mob/living/silicon/robot/borgy = user

	if(!diff)
		return
	// 25 is our cost per unit of paint, making it cost 25 energy per
	// normal tag, 50 per window, and 250 per attack
	var/cost = diff * 25
	// Cyborgs shouldn't be able to use modules without a cell. But if they do
	// it's free.
	if(borgy.cell)
		borgy.cell.use(cost)

/obj/item/toy/crayon/spraycan/hellcan
	name = "hellcan"
	desc = "This spraycan doesn't seem to be filled with paint..."
	icon_state = "deathcan2_cap"
	icon_capped = "deathcan2_cap"
	icon_uncapped = "deathcan2"
	use_overlays = FALSE

	volume_multiplier = 25
	charges = 100
	reagent_contents = list(/datum/reagent/clf3 = 1)
	actually_paints = FALSE
	paint_color = "#000000"

/obj/item/toy/crayon/spraycan/lubecan
	name = "slippery spraycan"
	desc = "You can barely keep hold of this thing."
	icon_state = "clowncan2_cap"
	icon_capped = "clowncan2_cap"
	icon_uncapped = "clowncan2"
	use_overlays = FALSE

	reagent_contents = list(/datum/reagent/lube = 1, /datum/reagent/consumable/banana = 1)
	volume_multiplier = 5

/obj/item/toy/crayon/spraycan/lubecan/isValidSurface(surface)
	return istype(surface, /turf/open/floor)

/obj/item/toy/crayon/spraycan/mimecan
	name = "silent spraycan"
	desc = "Art is best seen, not heard."
	icon_state = "mimecan_cap"
	icon_capped = "mimecan_cap"
	icon_uncapped = "mimecan"
	use_overlays = FALSE

	can_change_colour = FALSE
	paint_color = "#FFFFFF" //RGB

	pre_noise = FALSE
	post_noise = FALSE
	reagent_contents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/toxin/mutetoxin = 1)

/obj/item/toy/crayon/spraycan/infinite
	name = "infinite spraycan"
	charges = -1
	desc = "Now with 30% more bluespace technology."

#undef RANDOM_GRAFFITI
#undef RANDOM_LETTER
#undef RANDOM_PUNCTUATION
#undef RANDOM_SYMBOL
#undef RANDOM_DRAWING
#undef RANDOM_NUMBER
#undef RANDOM_ORIENTED
#undef RANDOM_RUNE
#undef RANDOM_ANY

#undef AVAILABLE_SPRAYCAN_SPACE
