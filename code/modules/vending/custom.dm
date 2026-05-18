/obj/machinery/vending/custom
	name = "Custom Vendor"
	icon_state = "custom"
	icon_deny = "custom-deny"
	max_integrity = 400
	payment_department = NO_FREEBIES
	light_mask = "custom-light-mask"
	refill_canister = /obj/item/vending_refill/custom
	/// where the money is sent
	var/datum/bank_account/linked_account
	/// max number of items that the custom vendor can hold
	var/max_loaded_items = 20
	/// Base64 cache of custom icons.
	var/list/base64_cache = list()
	panel_type = "panel20"

/obj/machinery/vending/custom/compartmentLoadAccessCheck(mob/user)
	. = FALSE
	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	var/obj/item/card/id/id_card = living_user.get_idcard(FALSE)
	if(id_card?.registered_account && id_card.registered_account == linked_account)
		return TRUE

/obj/machinery/vending/custom/canLoadItem(obj/item/I, mob/user)
	. = FALSE
	if(I.flags_1 & HOLOGRAM_1)
		say("This vendor cannot accept nonexistent items.")
		return
	if(loaded_items >= max_loaded_items)
		say("There are too many items in stock.")
		return
	if(istype(I, /obj/item/stack))
		say("Loose items may cause problems, try to use it inside wrapping paper.")
		return
	if(I.custom_price)
		return TRUE

/obj/machinery/vending/custom/ui_interact(mob/user)
	if(!linked_account)
		balloon_alert(user, "no registered owner")
		return FALSE
	return ..()

/obj/machinery/vending/custom/ui_data(mob/user)
	. = ..()
	.["access"] = compartmentLoadAccessCheck(user)
	.["vending_machine_input"] = list()
	for (var/O in vending_machine_input)
		if(vending_machine_input[O] > 0)
			var/base64
			var/price = 0
			for(var/obj/item/T in contents)
				if(format_text(T.name) == O)
					price = T.custom_price
					if(!base64)
						if(base64_cache[T.type])
							base64 = base64_cache[T.type]
						else
							base64 = icon2base64(getFlatIcon(T, no_anim=TRUE))
							base64_cache[T.type] = base64
					break
			var/list/data = list(
				name = O,
				price = price,
				img = base64,
				amount = vending_machine_input[O],
				colorable = FALSE
			)
			.["vending_machine_input"] += list(data)

/obj/machinery/vending/custom/attackby(obj/item/I, mob/user, params)
	if(!linked_account && isliving(user))
		var/mob/living/L = user
		var/obj/item/card/id/C = L.get_idcard(TRUE)
		if(C?.registered_account)
			linked_account = C.registered_account
			say("\The [src] has been linked to [C].")

	if(compartmentLoadAccessCheck(user))
		if(istype(I, /obj/item/pen))
			name = tgui_input_text(user, "Set name", "Name", name, 20)
			desc = tgui_input_text(user, "Set description", "Description", desc, 60)
			slogan_list += tgui_input_text(user, "Set slogan", "Slogan", "Epic", 60)
			last_slogan = world.time + rand(0, slogan_delay)
			return

	return ..()

/obj/machinery/vending/custom/crowbar_act(mob/living/user, obj/item/I)
	return FALSE

/obj/machinery/vending/custom/deconstruct(disassembled)
	for(var/obj/item/I in contents)
		I.forceMove(drop_location())
	. = ..()

/**
 * Vends an item to the user. Handles all the logic:
 * Updating stock, account transactions, alerting users.
 * @return -- TRUE if a valid condition was met, FALSE otherwise.
 */
/obj/machinery/vending/custom/vend(mob/living/user, delay = FALSE, item_name)
	if(!vend_ready)
		return

	user.animate_interact(src)

	var/obj/item/dispensed_item
	for(var/obj/stock in contents)
		if(format_text(stock.name) == item_name)
			dispensed_item = stock
			break

	if(!dispensed_item)
		return FALSE

	user.animate_interact(src)
	playsound(src, 'goon/sounds/button.ogg', 50)

	var/spent = pay_for_vend(user, dispensed_item)
	if(spent == -1)
		return FALSE

	if(delay)
		vend_ready = FALSE
		addtimer(CALLBACK(src, PROC_REF(complete_vend), user, dispensed_item, spent > 0), vend_delay_animation(), TIMER_DELETE_ME)
	else
		complete_vend(user, dispensed_item, spent > 0)
	return TRUE

/obj/machinery/vending/custom/complete_vend(mob/user, obj/item/vended_item, thank)
	vend_ready = TRUE
	if(!is_operational)
		return FALSE // Lol sucks to suck!

	if(thank)
		thank_shopper(user)

	if(icon_vend) //Show the vending animation if needed
		z_flick(icon_vend,src)

	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)

	// Remove the item
	loaded_items--
	give_or_drop_dispensed_item(user, vended_item)

	use_power(active_power_usage)
	vending_machine_input[format_text(vended_item.name)] = max(vending_machine_input[format_text(vended_item.name)] - 1, 0)

/obj/machinery/vending/custom/pay_for_vend(mob/vendor, obj/item/buying_item)
	if(compartmentLoadAccessCheck(vendor))
		return 0

	var/obj/item/card/id/C = astype(vendor, /mob/living)?.get_idcard(TRUE)
	var/datum/bank_account/account = C?.registered_account
	var/price_to_use = buying_item.custom_price
	var/deduct_cash = 0
	var/deduct_card = 0

	// It's free, record and return.
	if(!price_to_use)
		if(account)
			SSeconomy.track_purchase(account, price_to_use, name)
		return 0

	deduct_cash = min(contained_cash?.amount || 0, price_to_use)
	if(deduct_cash < price_to_use)
		if(!C)
			speak("Insufficient funds.")
			z_flick(icon_deny,src)
			return -1

		else if (!C.registered_account)
			speak("No account found.")
			z_flick(icon_deny,src)
			return -1

		deduct_card = price_to_use - deduct_cash
		if(!account.has_money(deduct_card))
			speak("Insufficient funds.")
			z_flick(icon_deny,src)
			return -1

	if(deduct_cash + deduct_card < price_to_use)
		speak("Insufficient funds.")
		z_flick(icon_deny,src)
		return -1

	// Deduct money from payment sources.
	contained_cash?.use(deduct_cash)
	account?.adjust_money(deduct_card)

	linked_account.adjust_money(price_to_use)

	// Log to administrator logs.
	SSblackbox.record_feedback("amount", "vending_spent", price_to_use)
	log_econ("[key_name(vendor)] paid [price_to_use] marks to purchase [buying_item] (machine owned by [linked_account.account_holder]).")
	return price_to_use

/obj/machinery/vending/custom/unbreakable
	name = "Indestructible Vendor"
	resistance_flags = INDESTRUCTIBLE

/obj/item/vending_refill/custom
	machine_name = "Custom Vendor"
	icon_state = "refill_custom"
	custom_premium_price = PAYCHECK_ASSISTANT

TYPEINFO_DEF(/obj/machinery/vending/custom/greed)
	default_materials = list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT * 5)

/obj/machinery/vending/custom/greed //name and like decided by the spawn
	icon_state = "greed"
	icon_deny = "greed-deny"
	panel_type = "panel4"
	light_mask = "greed-light-mask"

/obj/machinery/vending/custom/greed/Initialize(mapload)
	. = ..()
	//starts in a state where you can move it
	panel_open = TRUE
	set_anchored(FALSE)
	add_overlay(panel_type)
	//and references the deity
	name = "[GLOB.deity]'s Consecrated Vendor"
	desc = "A vending machine created by [GLOB.deity]."
	slogan_list = list("[GLOB.deity] says: It's your divine right to buy!")
	add_filter("vending_outline", 9, list("type" = "outline", "color" = COLOR_VERY_SOFT_YELLOW))
	add_filter("vending_rays", 10, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))
