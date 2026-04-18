/obj/item/card/id/testmap
	registered_name = "Taylor J."
	registered_age = "23"
	assignment = "Developer"

	var/found = FALSE

/obj/item/card/id/testmap/equipped(mob/user, slot, initial)
	. = ..()
	if(!found)
		found = TRUE
		SSnowhere.you_did_something_right()
