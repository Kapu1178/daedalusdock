/datum/dream/testmap
	dream_class = DREAM_CLASS_TESTMAP
	dream_cooldown = 2 MINUTE

/datum/dream/testmap/GenerateDream(mob/living/carbon/dreamer)
	. = list()

	var/list/strings = list(
		"Waking moon, weeping clouds" = 8 SECONDS,
		"You wake up, a storm rages outside the window" = 8 SECONDS,
		"You see a strange yellow symbol" = 8 SECONDS,
		"You see a feminine figure walking out of the front door" = 8 SECONDS,
		"A yellow figure looms over you" = 8 SECONDS,
	)

	shuffle_inplace(strings)
	return strings

/datum/dream/testmap/WrapMessage(mob/living/carbon/dreamer, message)
	return span_statsbad("<i>... [message] ...</i>")

/datum/dream/testmap/midnight
	dream_class = DREAM_CLASS_TESTMAP_MIDNIGHT
	dream_cooldown = 2 MINUTE

/datum/dream/testmap/midnight/GenerateDream(mob/living/carbon/dreamer)
	. = list()

	var/list/strings = list(
		"You are the heir to his kingdom" = 8 SECONDS,
		"Have you seen the yellow sign?" = 8 SECONDS,
		"He opens his cloak, holding you in his embrace" = 8 SECONDS,
	)
	shuffle_inplace(strings)
	return strings
