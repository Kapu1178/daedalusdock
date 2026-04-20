/datum/dream/testmap
	dream_class = DREAM_CLASS_TESTMAP
	dream_cooldown = 1 MINUTE

/datum/dream/testmap/GenerateDream(mob/living/carbon/dreamer)
	. = list()

	var/list/strings = list(
		"Waking moon, weeping clouds"
		"You wake up, a storm rages outside the window"
	)

/datum/dream/testmap/WrapMessage(mob/living/carbon/dreamer, message)
	return span_statsbad("<i>... [message] ...</i>")
