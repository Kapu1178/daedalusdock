/atom/movable/screen/text/screen_text/one_word_a_time
	letters_per_update = 1

/atom/movable/screen/text/screen_text/one_word_a_time/animate_text()
	var/static/html_locate_regex = regex("<\[^>\]+>")
	var/list/words = splittext_char(text_to_play, html_locate_regex, 1, 0 ,1)
	words.RemoveAll("")

	for(var/i = 1; i <= length(words); i++)
		if(words[i][1] == "<")
			continue

		var/sentence = words[i]
		words.Cut(i, i+1)
		words.Insert(i, splittext(sentence, " "))

	var/words_placed = 0
	for(var/index= 1 to length(words))
		if(words[index][1] == "<")
			continue

		words_placed++
		if(length(words) != index && words_placed != letters_per_update)
			continue

		words_placed = 0
		maptext = "[style_open][words.Join(" ", 1, index + 1)][style_close]"
		if(QDELETED(src))
			return
		sleep(play_delay)
