/obj/item/storage/pill_bottle/lsd/unmarked
	name = /obj/item/storage/pill_bottle::name
	desc = /obj/item/storage/pill_bottle::desc

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/lsd/unmarked(src)

/obj/item/reagent_containers/pill/lsd/unmarked
	name = /obj/item/reagent_containers/pill::name
	desc = /obj/item/reagent_containers/pill::desc

/obj/item/reagent_containers/pill/lsd/unmarked/Initialize(mapload)
	icon_state = null // parent call randomizes. not set in typedef so it appears in mapping.
	. = ..()
