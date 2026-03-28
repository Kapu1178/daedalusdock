/atom/movable/screen/text/screen_text/bell_toll
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_BLACKOUT_LAYER
	maptext_height = 128

	fade_in_time = 2 SECONDS
	fade_out_time = 2 SECONDS

	auto_end = FALSE

	letters_per_update = INFINITY

	style_open = "<span style='font-size:24px;text-align:center;vertical-align:top;-dm-text-outline: 1px black;'>"
	style_close = "</span>"

/atom/movable/screen/text/screen_text/bell_toll/animate_text()
	animate(maptext = "[style_open][text_to_play][style_close]", flags = ANIMATION_PARALLEL)

/atom/movable/screen/text/screen_text/bell_toll/countdown
	maptext_y = parent_type::maptext_y - 32

/atom/movable/screen/text/screen_text/bell_toll/subtext
	maptext_y = parent_type::maptext_y - 64
