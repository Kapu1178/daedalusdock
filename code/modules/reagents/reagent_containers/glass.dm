
/obj/item/reagent_containers/glass
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	reagent_flags = OPENCONTAINER | DUNKABLE
	spillable = TRUE
	resistance_flags = ACID_PROOF


/obj/item/reagent_containers/glass/attack(mob/M, mob/living/user, obj/target)
	if(!canconsume(M, user))
		return

	if(!spillable)
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return

	if(istype(M))
		if(M != user)
			M.visible_message(span_danger("[user] attempts to feed [M] something from [src]."), \
						span_userdanger("[user] attempts to feed you something from [src]."))
			if(!do_after(user, M, 3 SECONDS))
				return
			if(!reagents || !reagents.total_volume)
				return // The drink might be empty after the delay, such as by spam-feeding

			M.visible_message(span_danger("[user] feeds [M] something from [src]."), \
						span_userdanger("[user] feeds you something from [src]."))
			log_combat(user, M, "fed", reagents.get_reagent_log_string())
		else
			to_chat(user, span_notice("You swallow a gulp of [src]."))

		add_trace_DNA(M.get_trace_dna())
		SEND_SIGNAL(src, COMSIG_GLASS_DRANK, M, user)
		addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, trans_to), M, 5, TRUE, TRUE, FALSE, user, FALSE, INGEST), 5)
		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
		if(iscarbon(M))
			var/mob/living/carbon/carbon_drinker = M
			var/list/diseases = carbon_drinker.get_static_viruses()
			if(LAZYLEN(diseases))
				var/list/datum/pathogen/diseases_to_add = list()
				for(var/d in diseases)
					var/datum/pathogen/malady = d
					if(malady.spread_flags & PATHOGEN_SPREAD_CONTACT_FLUIDS)
						diseases_to_add += malady
				if(LAZYLEN(diseases_to_add))
					AddComponent(/datum/component/infective, diseases_to_add)

/obj/item/reagent_containers/glass/afterattack(obj/target, mob/living/user, proximity)
	. = ..()
	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	if(!spillable)
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty!"))
			return

		if(target.reagents.holder_full())
			to_chat(user, span_warning("[target] is full."))
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, span_notice("You transfer [trans] unit\s of the solution to [target]."))

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty and can't be refilled!"))
			return

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))

	target.update_appearance()

/obj/item/reagent_containers/glass/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if((!proximity_flag) || !check_allowed_items(target,target_self=1))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!spillable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty!"))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))

	target.update_appearance()
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/reagent_containers/glass/attackby(obj/item/I, mob/user, params)
	var/hotness = I.get_temperature()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, span_notice("You heat [name] with [I]!"))

	//Cooling method
	if(istype(I, /obj/item/extinguisher))
		var/obj/item/extinguisher/extinguisher = I
		if(extinguisher.safety)
			return
		if (extinguisher.reagents.total_volume < 1)
			to_chat(user, span_warning("\The [extinguisher] is empty!"))
			return
		var/cooling = (0 - reagents.chem_temp) * extinguisher.cooling_power * 2
		reagents.expose_temperature(cooling)
		to_chat(user, span_notice("You cool the [name] with the [I]!"))
		playsound(loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)
		extinguisher.reagents.remove_all(1)

	if(istype(I, /obj/item/food/egg)) //breaking eggs
		var/obj/item/food/egg/E = I
		if(reagents)
			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, span_notice("[src] is full."))
			else
				to_chat(user, span_notice("You break [E] in [src]."))
				E.reagents.trans_to(src, E.reagents.total_volume, transfered_by = user)
				qdel(E)
			return
	..()

/*
 * On accidental consumption, make sure the container is partially glass, and continue to the reagent_container proc
 */
/obj/item/reagent_containers/glass/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	if(!custom_materials)
		set_custom_materials(list(GET_MATERIAL_REF(/datum/material/glass) = 5))//sets it to glass so, later on, it gets picked up by the glass catch (hope it doesn't 'break' things lol)
	return ..()

TYPEINFO_DEF(/obj/item/reagent_containers/glass/beaker)
	default_materials = list(/datum/material/glass=500)

/obj/item/reagent_containers/glass/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 60 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	inhand_icon_state = "beaker"
	worn_icon_state = "beaker"
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 60)
	volume = 60

/obj/item/reagent_containers/glass/beaker/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/glass/beaker/get_part_rating()
	return reagents.maximum_volume

/obj/item/reagent_containers/glass/beaker/jar
	name = "honey jar"
	desc = "A jar for honey. It can hold up to 50 units of sweet delight."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vapour"

TYPEINFO_DEF(/obj/item/reagent_containers/glass/beaker/large)
	default_materials = list(/datum/material/glass=2500)

/obj/item/reagent_containers/glass/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 120 units."
	icon_state = "beakerlarge"
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,40,60,120)
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

TYPEINFO_DEF(/obj/item/reagent_containers/glass/beaker/plastic)
	default_materials = list(/datum/material/glass=2500, /datum/material/plastic=3000)

/obj/item/reagent_containers/glass/beaker/plastic
	name = "x-large beaker"
	desc = "An extra-large beaker. Can hold up to 150 units."
	icon_state = "beakerwhite"
	volume = 150
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,30,50,60,120,150)
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

TYPEINFO_DEF(/obj/item/reagent_containers/glass/beaker/meta)
	default_materials = list(/datum/material/glass=2500, /datum/material/plastic=3000, /datum/material/gold=1000, /datum/material/titanium=1000)

/obj/item/reagent_containers/glass/beaker/meta
	name = "metamaterial beaker"
	desc = "A large beaker. Can hold up to 180 units."
	icon_state = "beakergold"
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,30,40,60,120,180)
	fill_icon_thresholds = list(0, 1, 10, 25, 35, 50, 60, 80, 100)

TYPEINFO_DEF(/obj/item/reagent_containers/glass/beaker/noreact)
	default_materials = list(/datum/material/iron=3000)

/obj/item/reagent_containers/glass/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without \
		reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	reagent_flags = OPENCONTAINER | NO_REACT
	volume = 50
	amount_per_transfer_from_this = 10

TYPEINFO_DEF(/obj/item/reagent_containers/glass/beaker/bluespace)
	default_materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)

/obj/item/reagent_containers/glass/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology \
		and Element Cuban combined with the Compound Pete. Can hold up to \
		300 units."
	icon_state = "beakerbluespace"
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)

/obj/item/reagent_containers/glass/beaker/cryoxadone
	list_reagents = list(/datum/reagent/medicine/cryoxadone = 30)

/obj/item/reagent_containers/glass/beaker/sulfuric
	list_reagents = list(/datum/reagent/toxin/acid = 50)

/obj/item/reagent_containers/glass/beaker/slime
	list_reagents = list(/datum/reagent/toxin/slimejelly = 50)

/obj/item/reagent_containers/glass/beaker/large/bicaridine
	name = "bicaridine reserve tank"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 50)

/obj/item/reagent_containers/glass/beaker/large/kelotane
	name = "kelotane reserve tank"
	list_reagents = list(/datum/reagent/medicine/kelotane = 50)

/obj/item/reagent_containers/glass/beaker/large/dylovene
	name = "dylovene reserve tank"
	list_reagents = list(/datum/reagent/medicine/dylovene = 50)

/obj/item/reagent_containers/glass/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 50)

/obj/item/reagent_containers/glass/beaker/synthflesh
	list_reagents = list(/datum/reagent/medicine/synthflesh = 50)

TYPEINFO_DEF(/obj/item/reagent_containers/glass/bucket)
	default_armor = list(BLUNT = 10, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 75, ACID = 50)
	default_materials = list(/datum/material/iron=200)

/obj/item/reagent_containers/glass/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "bucket"
	inhand_icon_state = "bucket"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,70)
	volume = 70
	flags_inv = HIDEHAIR
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION
	slot_equipment_priority = list( \
		ITEM_SLOT_BACK, ITEM_SLOT_ID,\
		ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING,\
		ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_NECK,\
		ITEM_SLOT_FEET, ITEM_SLOT_GLOVES,\
		ITEM_SLOT_EARS, ITEM_SLOT_EYES,\
		ITEM_SLOT_BELT, ITEM_SLOT_SUITSTORE,\
		ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET,\
		ITEM_SLOT_DEX_STORAGE
	)

TYPEINFO_DEF(/obj/item/reagent_containers/glass/bucket/wooden)
	default_armor = list(BLUNT = 10, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 50)
	default_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 2)

/obj/item/reagent_containers/glass/bucket/wooden
	name = "wooden bucket"
	icon_state = "woodbucket"
	inhand_icon_state = "woodbucket"
	resistance_flags = FLAMMABLE
	supports_variations_flags = NONE

/obj/item/reagent_containers/glass/bucket/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, span_warning("[src] is out of water!"))
		else
			reagents.trans_to(O, 5, transfered_by = user)
			to_chat(user, span_notice("You wet [O] in [src]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	else if(isprox(O)) //This works with wooden buckets for now. Somewhat unintended, but maybe someone will add sprites for it soon(TM)
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/cleanbot)
	else
		..()

/obj/item/reagent_containers/glass/bucket/equipped(mob/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		if(reagents.total_volume)
			to_chat(user, span_userdanger("[src]'s contents spill all over you!"))
			reagents.expose(user, TOUCH)
			reagents.clear_reagents()
		reagents.flags = NONE

/obj/item/reagent_containers/glass/bucket/unequipped(mob/user)
	. = ..()
	reagents.flags = initial(reagent_flags)

/obj/item/reagent_containers/glass/bucket/equip_to_best_slot(mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(ITEM_SLOT_HEAD)
		slot_equipment_priority.Remove(ITEM_SLOT_HEAD)
		. = ..()
		slot_equipment_priority.Insert(index, ITEM_SLOT_HEAD)
		return
	return ..()

/obj/item/pestle
	name = "pestle"
	desc = "An ancient, simple tool used in conjunction with a mortar to grind or juice items."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pestle"
	force = 7

TYPEINFO_DEF(/obj/item/reagent_containers/glass/mortar)
	default_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT)

/obj/item/reagent_containers/glass/mortar
	name = "mortar"
	desc = "A specially formed bowl of ancient design. It is possible to crush or juice items placed in it using a pestle; however the process, unlike modern methods, is slow and physically exhausting. Alt click to eject the item."
	icon_state = "mortar"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 100)
	volume = 100
	reagent_flags = OPENCONTAINER
	spillable = TRUE
	var/obj/item/grinded

/obj/item/reagent_containers/glass/mortar/AltClick(mob/user)
	if(grinded)
		grinded.forceMove(drop_location())
		grinded = null
		to_chat(user, span_notice("You eject the item inside."))

/obj/item/reagent_containers/glass/mortar/attackby(obj/item/I, mob/living/carbon/human/user)
	..()
	if(istype(I,/obj/item/pestle))
		if(grinded)
			if(HAS_TRAIT(user, TRAIT_EXHAUSTED))
				to_chat(user, span_warning("You are too tired to work!"))
				return
			to_chat(user, span_notice("You start grinding..."))
			if((do_after(user, src, 25)) && grinded)
				user.stamina.adjust(-40)
				if(grinded.juice_results) //prioritize juicing
					grinded.juice(reagents)
					reagents.add_reagent_list(grinded.juice_results)
					to_chat(user, span_notice("You juice [grinded] into a fine liquid."))
					QDEL_NULL(grinded)
					return

				grinded.grind(reagents)

				to_chat(user, span_notice("You break [grinded] into powder."))
				QDEL_NULL(grinded)
				return
			return
		else
			to_chat(user, span_warning("There is nothing to grind!"))
			return
	if(grinded)
		to_chat(user, span_warning("There is something inside already!"))
		return
	if(I.juice_results || I.grind_results)
		I.forceMove(src)
		grinded = I
		return
	to_chat(user, span_warning("You can't grind this!"))

//TRUE MUGS for REAL MUG FANS !!!
/obj/item/reagent_containers/glass/mug
	name = "mug"
	desc = "A generic porcelain mug, ready to hold your warm beverage."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "tea_empty"
	inhand_icon_state = "coffee"
	fill_icon_state = "mug"
	fill_icon_thresholds = list(0, 40, 80, 100)
	volume = 30

/obj/item/reagent_containers/glass/mug/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/glass/mug/tea
	name = "Duke Purple tea"
	list_reagents = list(/datum/reagent/consumable/tea = 30)

/obj/item/reagent_containers/glass/mug/coco
	name = "Duke Purple tea"
	list_reagents = list(/datum/reagent/consumable/hot_coco = 15, /datum/reagent/consumable/sugar = 5)

/obj/item/reagent_containers/glass/mug/brit
	name = "mug"
	desc = "A mug with the british flag emblazoned on it."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "britcup"

/obj/item/reagent_containers/glass/mug/beagle
	name = "beagle mug"
	desc = "A mug, shaped like the head of a claymation beagle. What will they think of next?"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "beaglemug"
	fill_icon_state = null //it's not the right perspective to see inside. Don't blame me, we stole the sprite from baystation!
