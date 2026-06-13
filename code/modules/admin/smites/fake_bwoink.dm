/// Sends the target a fake adminhelp sound
/datum/smite/fake_bwoink
	name = "Fake bwoink"

/datum/smite/fake_bwoink/effect(client/user, mob/living/target)
	. = ..()
	SEND_SOUND(target, sound('sound/effects/adminhelp.ogg', channel = SSsounds.random_available_channel()))
