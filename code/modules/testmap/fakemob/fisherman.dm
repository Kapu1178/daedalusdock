/obj/effect/fakemob/fisherman
	name = "Fisherman"

	stare_at_mobs = FALSE
	dialogue = list("The water is movin' too fast. I can't catch nothin'.")

/obj/effect/fakemob/fisherman/create_meat_puppet()
	var/mob/living/carbon/human/dummy/consistent/puppet = ..()
	puppet.update_body_parts(TRUE)
	puppet.equipOutfit(/datum/outfit/fisherman)
	return puppet

/datum/outfit/fisherman
	head = /obj/item/clothing/head/scarecrow_hat/fisherman
	r_hand = /obj/item/spear
	uniform = /obj/item/clothing/under/costume/driscoll/fisherman
	suit = /obj/item/clothing/suit/apron/waders

/obj/item/clothing/head/scarecrow_hat/fisherman
	name = "straw hat"

/obj/item/clothing/under/costume/driscoll/fisherman
	name = "western outfit"

