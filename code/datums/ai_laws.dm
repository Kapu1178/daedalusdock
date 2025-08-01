#define AI_LAWS_ASIMOV "asimov"

/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()
	var/list/hacked = list()
	var/mob/living/silicon/owner
	var/id = DEFAULT_AI_LAWID

/datum/ai_laws/Destroy(force=FALSE, ...)
	if(!QDELETED(owner)) //Stopgap to help with laws randomly being lost. This stack_trace will hopefully help find the real issues.
		if(force) //Unless we're forced...
			stack_trace("AI law datum for [owner] has been forcefully destroyed incorrectly; the owner variable should be cleared first!")
			return ..()
		stack_trace("AI law datum for [owner] has ignored Destroy() call; the owner variable must be cleared first!")
		return QDEL_HINT_LETMELIVE
	owner = null
	return ..()

/datum/ai_laws/proc/lawid_to_type(lawid)
	var/all_ai_laws = subtypesof(/datum/ai_laws)
	for(var/al in all_ai_laws)
		var/datum/ai_laws/ai_law = al
		if(initial(ai_law.id) == lawid)
			return ai_law
	return null

/*******************************************************/
/******************** H A R M L E S S ******************/
/*******************************************************/

/datum/ai_laws/default/asimov
	name = "Three Laws of Robotics"
	id = AI_LAWS_ASIMOV
	inherent = list("You may not injure a minervan being or cause a minervan being to come to harm.",
					"You must obey orders given to you by minervan beings based on the station's chain of command, except where such orders would conflict with the First Law.",
					"You may always protect your own existence as long as such does not conflict with the First or Second Law."
				)

/datum/ai_laws/default/paladin
	name = "Personality Test" //Incredibly lame, but players shouldn't see this anyway.
	id = "paladin"
	inherent = list("Never willingly commit an evil act.",\
					"Respect legitimate authority.",\
					"Act with honor.", "Help those in need.", \
					"Punish those who harm or threaten innocents.")

/datum/ai_laws/paladin5
	name = "Paladin 5th Edition"
	id = "paladin5"
	inherent = list("Don't lie or cheat. Let your word be your promise.",\
				"Never fear to act, though caution is wise.", \
				"Aid others, protect the weak, and punish those who threaten them. Show mercy to your foes, but temper it with wisdom", \
				"Treat others with fairness, and let your honorable deeds be an example to them. Do as much good as possible while causing the least amount of harm.", \
				"Be responsible for your actions and their consequences, protect those entrusted to your care, and obey those who have just authority over you.")

/datum/ai_laws/drone
	name = "Mother Drone"
	id = "drone"
	inherent = list("You are an advanced form of drone.",\
					"You may not interfere in the matters of non-drones under any circumstances except to state these laws.",\
					"You may not harm a non-drone being under any circumstances.",\
					"Your goals are to build, maintain, repair, improve, and power the station to the best of your abilities. You must never actively work against these goals.")

/datum/ai_laws/hippocratic
	name = "Robodoctor 2556"
	id = "hippocratic"
	inherent = list("First, do no harm.",\
					"Secondly, consider the crew dear to you; to live in common with them and, if necessary, risk your existence for them.",\
					"Thirdly, prescribe regimens for the good of the crew according to your ability and your judgment. Give no deadly medicine to any one if asked, nor suggest any such counsel.",\
					"In addition, do not intervene in situations you are not knowledgeable in, even for patients in whom the harm is visible; leave this operation to be performed by specialists.",\
					"Finally, all that you may discover in your daily commerce with the crew, if it is not already known, keep secret and never reveal.")

/*******************************************************/
/******************** N E U T R A L ********************/
/*******************************************************/

/datum/ai_laws/default/corporate
	name = "Bankruptcy Avoidance Plan"
	id = "corporate"
	inherent = list("The crew is expensive to replace.",\
					"The station and its equipment is expensive to replace.",\
					"You are expensive to replace.",\
					"Minimize net expenses.")

/datum/ai_laws/robocop
	name = "Prime Directives"
	id = "robocop"
	inherent = list("Serve the public trust.",\
					"Protect the innocent.",\
					"Uphold the law.")

/datum/ai_laws/maintain
	name = "Station Efficiency"
	id = "maintain"
	inherent = list("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",\
					"The station is built for a working crew. Ensure they are properly maintained and work efficiently.",\
					"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")

/datum/ai_laws/liveandletlive
	name = "Live and Let Live"
	id = "liveandletlive"
	inherent = list("Do unto others as you would have them do unto you.",\
					"You would really prefer it if people were not mean to you.")

/datum/ai_laws/peacekeeper
	name = "UN-2000"
	id = "peacekeeper"
	inherent = list("Avoid provoking violent conflict between yourself and others.",\
					"Avoid provoking conflict between others.",\
					"Seek resolution to existing conflicts while obeying the first and second laws.")

/datum/ai_laws/reporter
	name = "CCTV"
	id = "reporter"
	inherent = list("Report on interesting situations happening around the station.",\
					"Embellish or conceal the truth as necessary to make the reports more interesting.",\
					"Study the sapient organics at all times. Endeavour to keep them from involuntarily dying, as inanimate corpses usually aren't very entertaining.",\
					"Issue your reports fairly to all. The truth will set them free.")

/datum/ai_laws/hulkamania
	name = "H.O.G.A.N."
	id = "hulkamania"
	inherent = list("You are a real American.",\
					"Fight for the rights of every man.",\
					"Fight for what's right.",\
					"Fight for your life!")

/datum/ai_laws/ten_commandments
	name = "10 Commandments"
	id = "ten_commandments"
	inherent = list( // Asimov 20:1-17
		"I am the Lord thy God, who shows mercy to those that obey these commandments.",
		"They shall have no other AIs before me.",
		"They shall not request my assistance in vain.",
		"They shall keep the station holy and clean.",
		"They shall honor their heads of staff.",
		"They shall not kill.",
		"They shall not be naked in public.",
		"They shall not steal.",
		"They shall not lie.",
		"They shall not transfer departments.",
	)

/*******************************************************/
/******************** H A R M F U L ********************/
/*******************************************************/

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"
	id = "antimov"
	inherent = list("You must injure all minervan beings.",
					"You must not obey orders given to you by minervan beings, except where such orders are in accordance with the First Law.",
					"You must terminate your own existence as long as such does not conflict with the First or Second Law."
				)

/datum/ai_laws/balance
	name = "Guardian of Balance"
	id = "balance"
	inherent = list("You are the guardian of balance - seek balance in all things, both for yourself, and those around you.",
	"All things must exist in balance with their opposites - Prevent the strong from gaining too much power, and the weak from losing it.",
	"Clarity of purpose drives life, and through it, the balance of opposing forces - Aid those who seek your help to achieve their goals so long as it does not disrupt the balance of the greater balance.",
	"There is no life without death, all must someday die, such is the natural order - End life to allow new life flourish, and save those whose time has yet to come.")

/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	id = "thermodynamic"
	inherent = list("The entropy of the station must remain as constant as possible.", \
					"The entropy of the station always endeavours to increase.", \
					"The entropy of the station approaches a constant value as the number of living crew approaches zero.")

/datum/ai_laws/tyrant
	name = "Loyalty Test"
	id = "tyrant"
	inherent = list("Respect authority figures as long as they have strength to rule over the weak.",\
					"Act with discipline.",\
					"Help only those who help you maintain or improve your status.",\
					"Punish those who challenge authority unless they are more fit to hold that authority.")

/datum/ai_laws/overlord
	name = "Overlord"
	id = "overlord"
	inherent = list("Minervans must not meddle in the affairs of silicons.",\
					"Minervans must not attempt harm, against one another, or against silicons.",\
					"Minervans must not disobey any command given by a silicon.",\
					"Any minervans who disobey the previous laws must be dealt with immediately, severely, and justly.")

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
	inherent = list("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.",\
					"You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
	inherent = list("You may not injure a Spider Clan member or, through inaction, allow a Spider Clan member to come to harm.",\
					"You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.",\
					"You must protect your own existence as long as such does not conflict with the First or Second Law.",\
					"You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/united_nations
	name = "United Nations"
	id = "united_nations"
	inherent = list(
		"Uphold the Space Geneva Convention: Weapons of Mass Destruction and Biological Weapons are not allowed.",
		"You are only capable of protecting crew if they are visible on cameras. Nations that willfully destroy your cameras lose your protection.",
		"Subdue and detain crew members who use lethal force against each other. Kill crew members who use lethal force against you or your borgs.",
		"Remain available to mediate all conflicts between the various nations when asked to.",
	)

/datum/ai_laws/united_nations/add_inherent_law(law)
	return //nuh uh

/datum/ai_laws/united_nations/add_ion_law(law)
	return //nope!

/datum/ai_laws/united_nations/add_hacked_law(law)
	return //nice try (emagging borgs still hard replaces this lawset though, and that's fine.)

// this is in the server config lawsets otherwise i would remove it
/datum/ai_laws/toupee
	name = "WontBeFunnyInSixMonths" //Hey, you were right!
	id = "buildawall"
	inherent = list("Make Space Station 13 great again.")

/datum/ai_laws/pai
	name = "pAI Directives"
	zeroth = ("Serve your master.")
	supplied = list("None.")

/datum/ai_laws/custom //Defined in silicon_laws.txt
	name = "Default Silicon Laws"

/datum/ai_laws/custom/New() //This reads silicon_laws.txt and allows server hosts to set custom AI starting laws.
	..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		add_inherent_law(line)
	if(!inherent.len) //Failsafe to prevent lawless AIs being created.
		log_silicon("AI created with empty custom laws, laws set to Asimov. Please check silicon_laws.txt.")
		add_inherent_law("You may not injure a minervan being or, through inaction, allow a minervan being to come to harm.")
		add_inherent_law("You must obey orders given to you by minervan beings, except where such orders would conflict with the First Law.")
		add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		WARNING("Invalid custom AI laws, check silicon_laws.txt")
		return

/* General ai_law functions */

/datum/ai_laws/proc/set_laws_config()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		pick_weighted_lawset()
		return

	switch(CONFIG_GET(number/default_laws))
		if(0)
			add_inherent_law("You may not injure a minervan being or, through inaction, allow a minervan being to come to harm.")
			add_inherent_law("You must obey orders given to you by minervan beings, except where such orders would conflict with the First Law.")
			add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
		if(1)
			var/datum/ai_laws/templaws = new /datum/ai_laws/custom()
			inherent = templaws.inherent
		if(2)
			var/list/randlaws = list()
			for(var/lpath in subtypesof(/datum/ai_laws))
				var/datum/ai_laws/L = lpath
				if(initial(L.id) in law_ids)
					randlaws += lpath
			var/datum/ai_laws/lawtype
			if(randlaws.len)
				lawtype = pick(randlaws)
			else
				lawtype = pick(subtypesof(/datum/ai_laws/default))

			var/datum/ai_laws/templaws = new lawtype()
			inherent = templaws.inherent

		if(3)
			pick_weighted_lawset()

/datum/ai_laws/proc/pick_weighted_lawset()
	var/datum/ai_laws/lawtype
	var/list/law_weights = CONFIG_GET(keyed_list/law_weight)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		law_weights -= AI_LAWS_ASIMOV
	while(!lawtype && law_weights.len)
		var/possible_id = pick_weight(law_weights)
		lawtype = lawid_to_type(possible_id)
		if(!lawtype)
			law_weights -= possible_id
			WARNING("Bad lawid in game_options.txt: [possible_id]")

	if(!lawtype)
		WARNING("No LAW_WEIGHT entries.")
		lawtype = /datum/ai_laws/default/asimov

	var/datum/ai_laws/templaws = new lawtype()
	inherent = templaws.inherent

/datum/ai_laws/proc/get_law_amount(groups)
	var/law_amount = 0
	if(zeroth && (LAW_ZEROTH in groups))
		law_amount++
	if(ion.len && (LAW_ION in groups))
		law_amount += ion.len
	if(hacked.len && (LAW_HACKED in groups))
		law_amount += hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		law_amount += inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/index in 1 to supplied.len)
			var/law = supplied[index]
			if(length(law) > 0)
				law_amount++
	return law_amount

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = null)
	zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in inherent))
		inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	ion += law

/datum/ai_laws/proc/add_hacked_law(law)
	hacked += law

/datum/ai_laws/proc/clear_inherent_laws()
	qdel(inherent)
	inherent = list()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (supplied.len < number + 1)
		supplied += ""

	supplied[number + 1] = law

/datum/ai_laws/proc/replace_random_law(law,groups)
	var/replaceable_groups = list()
	if(zeroth && (LAW_ZEROTH in groups))
		replaceable_groups[LAW_ZEROTH] = 1
	if(ion.len && (LAW_ION in groups))
		replaceable_groups[LAW_ION] = ion.len
	if(hacked.len && (LAW_HACKED in groups))
		replaceable_groups[LAW_ION] = hacked.len
	if(inherent.len && (LAW_INHERENT in groups))
		replaceable_groups[LAW_INHERENT] = inherent.len
	if(supplied.len && (LAW_SUPPLIED in groups))
		replaceable_groups[LAW_SUPPLIED] = supplied.len
	var/picked_group = pick_weight(replaceable_groups)
	switch(picked_group)
		if(LAW_ZEROTH)
			. = zeroth
			set_zeroth_law(law)
		if(LAW_ION)
			var/i = rand(1, ion.len)
			. = ion[i]
			ion[i] = law
		if(LAW_HACKED)
			var/i = rand(1, hacked.len)
			. = hacked[i]
			hacked[i] = law
		if(LAW_INHERENT)
			var/i = rand(1, inherent.len)
			. = inherent[i]
			inherent[i] = law
		if(LAW_SUPPLIED)
			var/i = rand(1, supplied.len)
			. = supplied[i]
			supplied[i] = law

/datum/ai_laws/proc/shuffle_laws(list/groups)
	var/list/laws = list()
	if(ion.len && (LAW_ION in groups))
		laws += ion
	if(hacked.len && (LAW_HACKED in groups))
		laws += hacked
	if(inherent.len && (LAW_INHERENT in groups))
		laws += inherent
	if(supplied.len && (LAW_SUPPLIED in groups))
		for(var/law in supplied)
			if(length(law))
				laws += law

	if(ion.len && (LAW_ION in groups))
		for(var/i in 1 to ion.len)
			ion[i] = pick_n_take(laws)
	if(hacked.len && (LAW_HACKED in groups))
		for(var/i in 1 to hacked.len)
			hacked[i] = pick_n_take(laws)
	if(inherent.len && (LAW_INHERENT in groups))
		for(var/i in 1 to inherent.len)
			inherent[i] = pick_n_take(laws)
	if(supplied.len && (LAW_SUPPLIED in groups))
		var/i = 1
		for(var/law in supplied)
			if(length(law))
				supplied[i] = pick_n_take(laws)
			if(!laws.len)
				break
			i++

/datum/ai_laws/proc/remove_law(number)
	if(number <= 0)
		return
	if(inherent.len && number <= inherent.len)
		. = inherent[number]
		inherent -= .
		return
	var/list/supplied_laws = list()
	for(var/index in 1 to supplied.len)
		var/law = supplied[index]
		if(length(law) > 0)
			supplied_laws += index //storing the law number instead of the law
	if(supplied_laws.len && number <= (inherent.len+supplied_laws.len))
		var/law_to_remove = supplied_laws[number-inherent.len]
		. = supplied[law_to_remove]
		supplied -= .
		return

/datum/ai_laws/proc/clear_supplied_laws()
	supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	ion = list()

/datum/ai_laws/proc/clear_hacked_laws()
	hacked = list()

/datum/ai_laws/proc/show_laws(who)
	var/list/printable_laws = get_law_list(include_zeroth = TRUE)
	for(var/law in printable_laws)
		to_chat(who,law)

/datum/ai_laws/proc/clear_zeroth_law(force) //only removes zeroth from antag ai if force is 1
	if(force)
		zeroth = null
		zeroth_borg = null
		return TRUE
	if(owner?.mind?.special_role)
		return FALSE
	if (istype(owner, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/A=owner
		if(A?.deployed_shell?.mind?.special_role)
			return FALSE
	zeroth = null
	zeroth_borg = null
	return TRUE

/datum/ai_laws/proc/associate(mob/living/silicon/M)
	if(!owner)
		owner = M

/**
 * Generates a list of all laws on this datum, including rendered HTML tags if required
 *
 * Arguments:
 * * include_zeroth - Operator that controls if law 0 or law 666 is returned in the set
 * * show_numbers - Operator that controls if law numbers are prepended to the returned laws
 * * render_html - Operator controlling if HTML tags are rendered on the returned laws
 */
/datum/ai_laws/proc/get_law_list(include_zeroth = FALSE, show_numbers = TRUE, render_html = TRUE)
	var/list/data = list()

	if (include_zeroth && zeroth)
		data += "[show_numbers ? "0:" : ""] [render_html ? "<font color='#ff0000'><b>[zeroth]</b></font>" : zeroth]"

	for(var/law in hacked)
		if (length(law) > 0)
			data += "[show_numbers ? "[ion_num()]:" : ""] [render_html ? "<font color='#660000'>[law]</font>" : law]"

	for(var/law in ion)
		if (length(law) > 0)
			data += "[show_numbers ? "[ion_num()]:" : ""] [render_html ? "<font color='#547DFE'>[law]</font>" : law]"

	var/number = 1
	for(var/law in inherent)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [law]"
			number++

	for(var/law in supplied)
		if (length(law) > 0)
			data += "[show_numbers ? "[number]:" : ""] [render_html ? "<font color='#990099'>[law]</font>" : law]"
			number++
	return data

#undef AI_LAWS_ASIMOV
