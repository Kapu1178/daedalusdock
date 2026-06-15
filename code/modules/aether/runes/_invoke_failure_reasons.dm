// Structs, never actually instanced.
/datum/invoke_failure
	var/desc = ""

/// Graceful failure such as the rune being qdeleted. This has NO SIDE EFFECTS.
/datum/invoke_failure/graceful

/// Invoker became incapacitated.
/datum/invoke_failure/invoker_incap

/// Helper removed their hand.
/datum/invoke_failure/helper_hand_removed
	desc = "a helper removed their hand"

/// The target mob moved.
/datum/invoke_failure/target_mob_moved
	desc = "the subject moved"

/// The target mob stood up.
/datum/invoke_failure/target_mob_getup
	desc = "the subject getting up off the floor"

/// Invoker isn't holding the tome.
/datum/invoke_failure/tome_gone
	desc = "you are not holding the tome"

/// Target item moved out of range.
/datum/invoke_failure/target_item_range
	desc = "a component moved outside of the ring"

/// HE'S ALIIIIIVE
/datum/invoke_failure/revival/target_alive
	desc = "the subject is alive"
