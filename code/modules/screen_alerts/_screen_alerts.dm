/**
 * proc for playing a screen_text on a mob.
 * enqueues it if a screen text is running and plays i otherwise
 * Arguments:
 * * text: text we want to be displayed
 * * alert_type: typepath for screen text type we want to play here
 */
/mob/proc/play_screen_text(text, alert = /atom/movable/screen/text/screen_text)
	set waitfor = FALSE
	if(!client)
		return

	var/atom/movable/screen/text/screen_text/text_box
	if(ispath(alert))
		text_box = new alert()
	else
		text_box = alert

	if(text)
		text_box.text_to_play = text

	. = text_box
	LAZYADD(client.screen_texts, text_box)
	text_box.owner_ref = WEAKREF(client)
	text_box.play_to_client()

/atom/movable/screen/text/screen_text
	icon = null
	icon_state = null
	alpha = 0
	plane = HUD_PLANE

	maptext_height = 64
	maptext_width = 480
	maptext_x = 0
	maptext_y = 0
	screen_loc = "LEFT,TOP-3"

	///A weakref to the client this belongs to
	var/datum/weakref/owner_ref

	///Time taken to fade in as we start printing text
	var/fade_in_time = 0
	///Time before fade out after printing is finished
	var/fade_out_delay = 8 SECONDS
	///Time taken when fading out after fade_out_delay
	var/fade_out_time = 0.5 SECONDS
	///delay between playing each letter. in general use 1 for fluff and 0.5 for time sensitive messsages
	var/play_delay = 1
	///letters to update by per text to per play_delay
	var/letters_per_update = 1

	///opening styling for the message
	var/style_open = "<span class='maptext' style=font-size:20pt;text-align:center valign='top'>"
	///closing styling for the message
	var/style_close = "</span>"
	///var for the text we are going to play
	var/text_to_play

	/// Should this automatically end?
	var/auto_end = TRUE

	/// Set when the screen text starts to fade out. Is not set if the screen text doesn't fade.
	var/fading = FALSE

/atom/movable/screen/text/screen_text/Destroy()
	if(owner_ref)
		remove_from_screen()
	return ..()

/**
 * proc for actually playing this screen_text on a mob.
 */
/atom/movable/screen/text/screen_text/proc/play_to_client()

	var/client/owner = owner_ref.resolve()
	if(!owner)
		return

	owner.screen += src

	if(fade_in_time)
		animate(src, alpha = 255, time = fade_in_time)
	else
		alpha = 255

	animate_text()

	if(auto_end)
		addtimer(CALLBACK(src, PROC_REF(fade_out)), fade_out_delay)

/atom/movable/screen/text/screen_text/proc/animate_text()
	var/list/lines_to_skip = list()
	var/static/html_locate_regex = regex("<.*>")
	var/tag_position = findtext(text_to_play, html_locate_regex)
	var/reading_tag = TRUE

	while(tag_position)
		if(reading_tag)
			if(text_to_play[tag_position] == ">")
				reading_tag = FALSE
				lines_to_skip += tag_position
			else
				lines_to_skip += tag_position
			tag_position++
		else
			tag_position = findtext(text_to_play, html_locate_regex, tag_position)
			reading_tag = TRUE

	for(var/letter = 2 to length(text_to_play) + letters_per_update step letters_per_update)
		if(letter in lines_to_skip)
			continue

		animate(maptext = "[style_open][copytext_char(text_to_play, 1, letter)][style_close]", flags = ANIMATION_PARALLEL)
		if(QDELETED(src))
			return
		sleep(play_delay)

///handles post-play effects like fade out after the fade out delay
/atom/movable/screen/text/screen_text/proc/fade_out()
	fading = TRUE
	if(!fade_out_time)
		end_play()
		return

	animate(src, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, PROC_REF(end_play)), fade_out_time)

///ends the play then deletes this screen object.
/atom/movable/screen/text/screen_text/proc/end_play()
	remove_from_screen()
	qdel(src)

/atom/movable/screen/text/screen_text/proc/remove_from_screen()
	var/client/owner = owner_ref.resolve()
	if(isnull(owner))
		return

	owner.screen -= src
	LAZYREMOVE(owner.screen_texts, src)
