GLOBAL_DATUM_INIT(success_roll, /datum/roll_result/success, new)
/**
 * Perform a stat roll, returning a roll result datum.
 *
 *
 * args:
 * * requirement (int) The baseline value required to roll a Success.
 * * stat (string) The stat, if applicable, to take into account.
 * * modifier (int) A modifier applied to the value after roll. Lower means the roll is more difficult.
 * * crit_fail_modifier (int) A value subtracted from the requirement, which dictates the crit fail threshold.
 */
/mob/living/proc/stat_roll(requirement = STATS_BASELINE_VALUE, datum/rpg_skill/skill_path, modifier = 0, crit_fail_modifier = -10, mob/living/defender)
	RETURN_TYPE(/datum/roll_result)

	var/datum/rpg_skill/checked_skill_path = skill_path

	/// The entertainer specifically always uses Sock and Buskin because that's funny.
	if(skill_path && mind?.assigned_role?.title == JOB_CLOWN)
		checked_skill_path = /datum/rpg_skill/theatre

	var/skill_mod = checked_skill_path ? stats.get_skill_modifier(checked_skill_path) : 0
	var/stat_mod = checked_skill_path ? stats.get_stat_modifier(initial(checked_skill_path.parent_stat_type)) : 0

	if(defender && skill_path)
		skill_mod -= defender.stats?.get_skill_modifier(skill_path) || 0
		stat_mod += defender.stats?.get_stat_modifier(initial(skill_path.parent_stat_type)) || 0

	requirement -= stat_mod

	return roll_3d6(requirement, (skill_mod + modifier), crit_fail_modifier, skill_type_used = skill_path)

// Handy probabilities for you!
// 3 - 100.00
// 4 - 99.54
// 5 - 98.15
// 6 - 95.37
// 7 - 90.74
// 8 - 83.80
// 9 - 74.07
// 10 - 62.50
// 11 - 50.00
// 12 - 37.50
// 13 - 25.93
// 14 - 16.20
// 15 - 9.26
// 16 - 4.63
// 17 - 1.85
// 18 - 0.46
/proc/roll_3d6(requirement = STATS_BASELINE_VALUE, modifier, crit_fail_modifier = -10, datum/rpg_skill/skill_type_used)
	RETURN_TYPE(/datum/roll_result)

	var/dice = roll("3d6")
	var/dice_after_mod = dice + modifier
	var/crit_fail = max((requirement + crit_fail_modifier), 4)
	var/crit_success = min((requirement + 7), 17)

	// if(dice >= requirement)
	// 	var/list/out = list(
	// 		"ROLL: [dice] ([modifier >= 0 ? "+[modifier]" : "-[modifier]"])",
	// 		"SUCCESS PROB: %[round(dice_probability(3, 6, requirement - modifier), 0.01)]",
	// 		"CRIT SP: %[round(dice_probability(3, 6, crit_success), 0.01)]",
	// 		"MOD: [modifier]",
	// 		"LOWEST POSSIBLE: [3 + modifier]",
	// 		"HIGHEST POSSIBLE:[18 + modifier]",
	// 		"CRIT SUCCESS: [crit_success]",
	// 		"SUCCESS: [requirement]",
	// 		"FAIL: [requirement-1]",
	// 		"CRIT FAIL:[crit_fail]",
	// 		"~~~~~~~~~~~~~~~"
	// 	)
	// 	to_chat(world, span_adminnotice(jointext(out, "")))

	var/datum/roll_result/result = new()
	result.roll = dice
	result.modifier = modifier
	result.requirement = requirement
	result.skill_type_used = skill_type_used
	result.calculate_probability()

	if(dice_after_mod >= requirement)
		if(dice_after_mod >= crit_success)
			result.outcome = CRIT_SUCCESS
		else
			result.outcome = SUCCESS

	else
		if(dice_after_mod <= crit_fail)
			result.outcome = CRIT_FAILURE
		else
			result.outcome = FAILURE

	return result

/datum/roll_result
	/// Outcome of the roll, failure, success, etc.
	var/outcome
	/// The % chance to have rolled a success (0-100)
	var/success_prob
	/// The numerical value rolled.
	var/roll
	/// The value required to pass the roll.
	var/requirement
	/// The modifier attached to the roll.
	var/modifier

	/// Typepath of the skill used. Optional.
	var/datum/rpg_skill/skill_type_used

	/// Cache of the dice svg strings used in create_tooltip. Created in create_tooltip.
	var/dice_svg_cache
	/// How many times this result was pulled from a result cache.
	var/cache_reads = 0

/datum/roll_result/proc/calculate_probability()
	success_prob = round(dice_probability(3, 6, clamp(requirement - modifier, 0, 18)), 0.01)


/datum/roll_result/proc/create_tooltip(body, body_only = FALSE)
	if(!skill_type_used)
		if(outcome >= SUCCESS)
			body = span_statsgood(body)
		else
			body = span_statsbad(body)
		return body

	if(!dice_svg_cache)
		dice_svg_cache = generate_dice()

	var/prob_string
	switch(success_prob)
		if(0 to 12)
			prob_string = "Impossible"
		if(13 to 24)
			prob_string = "Legendary"
		if(25 to 36)
			prob_string = "Formidable"
		if(37 to 48)
			prob_string = "Challenging"
		if(49 to 60)
			prob_string = "Hard"
		if(61 to 72)
			prob_string = "Medium"
		if(73 to 84)
			prob_string = "Easy"
		if(85 to 100)
			prob_string = "Trivial"

	var/success = ""
	switch(outcome)
		if(CRIT_SUCCESS)
			success = "Critical Success"
		if(SUCCESS)
			success = "Success"
		if(FAILURE)
			success = "Failure"
		if(CRIT_FAILURE)
			success = "Critical Failure"

	var/finished_prob_string = "<span style='color: #bbbbad;font-style: italic'>\[[prob_string]: [success]\]</span>"
	var/prefix
	if(outcome >= SUCCESS)
		prefix = "<span class='statsGood' style='text-shadow: inherit;'>[uppertext(initial(skill_type_used.name))]</span> "
		body = span_statsgood(body)
	else
		prefix = "<span class='statsBad' style='text-shadow: inherit;'>[uppertext(initial(skill_type_used.name))]</span> "
		body = span_statsbad(body)

	var/modifier_string = ""
	if(modifier)
		var/modifier_string_inner = modifier > 0 ? "+[modifier]" : "[modifier]"
		var/modifier_class = (modifier >= 0) ? "statsGood" : "statsBad"
		modifier_string = " (<span class='[modifier_class]' style='font-weight: bold;text-shadow: inherit;font-style: inherit'>[modifier_string_inner]</span>)"

	var/result_class = (outcome >= SUCCESS) ? "statsGood" : "statsBad"
	var/result_string = "Result: <span class='[result_class]' style='font-weight: bold;text-shadow: inherit;font-style: inherit'><b>[roll]</b></span>[modifier_string]"
	var/tooltip_html = "<div>[success_prob]% | [result_string] | Check: <b>[requirement]</b></div><div style='display: flex;flex-direction: horizontal;justify-content: center;'>[dice_svg_cache]</div>"
	var/seperator = "<span style='color: #bbbbad;font-style: italic'>: </span>"

	if(body_only)
		return body
	return "[prefix]<span data-component=\"Tooltip\" data-innerhtml=\"[html_encode(tooltip_html)]\" data-position=\"top\" class=\"tooltip\">[finished_prob_string]</span>[seperator][body]"

/datum/roll_result/proc/generate_dice()
	var/alist/die1_choices = alist()

	var/remaining_sum = roll
	for(var/value in 1 to 6)
		remaining_sum = roll - value
		var/weight = max(0, 6 - abs(remaining_sum - 7))
		if(weight)
			die1_choices[value] = weight

	var/die1 = pick_weight(die1_choices)
	remaining_sum = roll - die1

	var/min_die2 = max(1, remaining_sum - 6)
	var/max_die2 = min(6, remaining_sum - 1)

	var/die2 = rand(min_die2, max_die2)
	var/die3 = remaining_sum - die2

	return "<div>[dice_svg(die1)]</div><div>[dice_svg(die2)]</div><div>[dice_svg(die3)]</div>"

/// Play
/datum/roll_result/proc/do_skill_sound(mob/user)
	if(isnull(skill_type_used) || cache_reads)
		return

	var/datum/rpg_stat/stat_path = initial(skill_type_used.parent_stat_type)
	var/sound_path = initial(stat_path.sound)
	SEND_SOUND(user, sound(sound_path, channel = SSsounds.random_available_channel()))

/datum/roll_result/success
	outcome = SUCCESS
	success_prob = 100
	roll = 18
	requirement = 3

/datum/roll_result/critical_success
	outcome = CRIT_SUCCESS
	success_prob = 100
	roll = 18
	requirement = 3

/datum/roll_result/critical_failure
	outcome = CRIT_FAILURE
	success_prob = 0
	roll = 1
	requirement = 18

/// Returns a number between 0 and 100 to roll the desired value when rolling the given dice.
/proc/dice_probability(num, sides, desired)
	var/static/list/outcomes_cache = new /list(0, 0)
	var/static/list/desired_cache = list()

	. = desired_cache["[num][sides][desired]"]
	if(!isnull(.))
		return .

	if(desired < sides)
		. = desired_cache["[num][sides][desired]"] = 100
		return

	if(desired > num * sides)
		. = desired_cache["[num][sides][desired]"] = 0
		return

	if(num > length(outcomes_cache))
		outcomes_cache.len = num

	if(sides > length(outcomes_cache[num]))
		if(islist(outcomes_cache[num]))
			outcomes_cache[num]:len = sides
		else
			outcomes_cache[num] = new /list(sides)

	var/list/outcomes = outcomes_cache[num][sides]
	if(isnull(outcomes))
		outcomes = outcomes_cache[num][sides] = dice_outcome_map(num, sides)

	var/favorable_outcomes = 0
	for(var/i in desired to num*sides)
		favorable_outcomes += outcomes[i]

	. = desired_cache["[num][sides][desired]"] = (favorable_outcomes / (sides ** num)) * 100

/// Certified LummoxJR code, this returns an array which is a map of outcomes to roll [index] value.
/proc/dice_outcome_map(n, sides)
	var/i,j,k
	var/list/outcomes = new(sides)
	var/list/next
	// 1st die
	for(i in 1 to sides)
		outcomes[i] = 1
	for(k in 2 to n)
		next = new(k*sides)
		for(i in 1 to k-1)
			next[i] = 0
		for(i in 1 to sides)
			for(j in k-1 to length(outcomes))
				next[i+j] += outcomes[j]
		outcomes = next
	return outcomes

/proc/dice_svg(face = 1, width = "32px", height = "32px")
	var/face_str
	switch(face)
		if(1)
			face_str = {"
				<g>
					<rect class="die-bg" x="2" y="2" width="96" height="96" />
					<circle class="pip" cx="50" cy="50" />
				</g>
			"}
		if(2)
			face_str = {"
				<g>
					<rect class="die-bg" x="2" y="2" width="96" height="96" />
					<circle class="pip" cx="26" cy="26" />
					<circle class="pip" cx="74" cy="74" />
				</g>
			"}
		if(3)
			face_str = {"
				<g>
					<rect class="die-bg" x="2" y="2" width="96" height="96" />
					<circle class="pip" cx="26" cy="26" />
					<circle class="pip" cx="50" cy="50" />
					<circle class="pip" cx="74" cy="74" />
				</g>
			"}
		if(4)
			face_str = {"
				<g>
					<rect class="die-bg" x="2" y="2" width="96" height="96" />
					<circle class="pip" cx="26" cy="26" />
					<circle class="pip" cx="74" cy="26" />
					<circle class="pip" cx="26" cy="74" />
					<circle class="pip" cx="74" cy="74" />
				</g>
			"}
		if(5)
			face_str = {"
				<g>
					<rect class="die-bg" x="2" y="2" width="96" height="96" />
					<circle class="pip" cx="26" cy="26" />
					<circle class="pip" cx="74" cy="26" />
					<circle class="pip" cx="50" cy="50" />
					<circle class="pip" cx="26" cy="74" />
					<circle class="pip" cx="74" cy="74" />
				</g>
			"}
		if(6)
			face_str = {"
				<g>
					<rect class="die-bg" x="2" y="2" width="96" height="96" />
					<circle class="pip" cx="26" cy="26" />
					<circle class="pip" cx="74" cy="26" />
					<circle class="pip" cx="26" cy="50" />
					<circle class="pip" cx="74" cy="50" />
					<circle class="pip" cx="26" cy="74" />
					<circle class="pip" cx="74" cy="74" />
				</g>
			"}

	var/static/regex/regex = regex(@"[\n\t]", "g")
	return replacetext({"
		<svg viewBox="0 0 100 100" width="[width]" height="[height]">
		<defs>
			<style>
			.die-bg { fill: #ffffff; stroke: #000000; stroke-width: 4; rx: 12px; }
			.pip { fill: #000000; r: 8; }
			</style>
		</defs>
		[face_str]
		</svg>
	"}, regex, "")
