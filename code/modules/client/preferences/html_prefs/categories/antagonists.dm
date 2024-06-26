/datum/preference_group/category/antagonists
	name = "Antagonists"
	priority = 30

	modules = list(
		/datum/preference_group/antagonists
	)

/datum/preference_group/category/antagonists/get_content(datum/preferences/prefs)
	. = ..()
	for(var/datum/preference_group/module as anything in modules)
		. += module.get_content(prefs)

/datum/preference_group/antagonists

/datum/preference_group/antagonists/get_content(datum/preferences/prefs)
	. = ..()
	. += {"
	<fieldset class='computerPaneNested' style='display: inline-block;min-width:50%;max-width:50%;margin-left: auto;margin-right: auto'>
		<legend class='computerLegend tooltip'>
			<b>Antagonists</b>
			<span class='tooltiptext'>Trouble lurks in the tunnels... you.</span>
		</legend>
		<div style='text-align: center'>
			[button_element(prefs, "Select All", "pref_act=[/datum/preference/blob/antagonists];select_all=1")]
			[button_element(prefs, "Deselect All", "pref_act=[/datum/preference/blob/antagonists];deselect_all=1")]
		</div>
	<div class='flexColumn' style='height: 560px;display: block;overflow-y: scroll'>
	"}
	var/list/client_antags = sort_list(prefs.read_preference(/datum/preference/blob/antagonists))

	var/i = 0
	var/background_color = "#7c5500"
	for(var/antagonist in client_antags)
		i++
		background_color = i %% 2 ? "#7c5500" : "#533200"
		. += {"
		<div class='flexRow' style='justify-content: space-between; background-color:[background_color]'>
			<div style='padding-left: 0.5em;padding-right: 0.5em'>
				<span class='computerText'>[antagonist]</span>
			</div>
			<div>
				[button_element(prefs, client_antags[antagonist] ? "ENABLED" : "DISABLED", "pref_act=[/datum/preference/blob/antagonists];toggle_antag=[antagonist]", style = "margin-right: 0.5em")]</td>
			</div>
		</div>
		"}
	. += "</div></fieldset>"
