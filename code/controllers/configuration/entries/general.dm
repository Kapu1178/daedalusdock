/// if autoadmin is enabled
/datum/config_entry/flag/autoadmin
	protection = CONFIG_ENTRY_LOCKED

/// the rank given to autoadmins
/datum/config_entry/string/autoadmin_rank
	default = "Game Master"
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/auto_deadmin_players
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/number/auto_deadmin_timegate
	default = null
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/auto_deadmin_antagonists
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/auto_deadmin_heads
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/auto_deadmin_silicons
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/auto_deadmin_security
	protection = CONFIG_ENTRY_LOCKED


/// server name (the name of the game window)
/datum/config_entry/string/servername

/// short form server name used for the DB
/datum/config_entry/string/serversqlname

/// station name (the name of the station in-game)
/datum/config_entry/string/stationname

/// the line of text under server name on the hub
/datum/config_entry/string/hub_subtitle

/// Countdown between lobby and the round starting.
/datum/config_entry/number/lobby_countdown
	default = 120
	integer = FALSE
	min_val = 0

/// Post round murder death kill countdown.
/datum/config_entry/number/round_end_countdown
	default = 90
	integer = FALSE
	min_val = 0

/// Time between the round ending and credits beginning to roll
/datum/config_entry/number/eor_credits_delay
	default = 40
	integer = FALSE
	min_val = 0

/// if the game appears on the hub or not
/datum/config_entry/flag/hub

/// Pop requirement for the server to be removed from the hub
/datum/config_entry/number/max_hub_pop
	default = 0 //0 means disabled
	integer = TRUE
	min_val = 0

/// log messages sent in OOC
/datum/config_entry/flag/log_ooc

/// log login/logout
/datum/config_entry/flag/log_access

/// Config entry which special logging of failed logins under suspicious circumstances.
/datum/config_entry/flag/log_suspicious_login

/// log client say
/datum/config_entry/flag/log_say

/// log admin actions
/datum/config_entry/flag/log_admin
	protection = CONFIG_ENTRY_LOCKED

/// log prayers
/datum/config_entry/flag/log_prayer

/// log silicons
/datum/config_entry/flag/log_silicon

/datum/config_entry/flag/log_law
	deprecated_by = /datum/config_entry/flag/log_silicon

/datum/config_entry/flag/log_law/DeprecationUpdate(value)
	return value

/// log usage of tools
/datum/config_entry/flag/log_tools

/// log graffiti
/datum/config_entry/flag/log_graffiti

/// log game events
/datum/config_entry/flag/log_game

/// log mech data
/datum/config_entry/flag/log_mecha

/// log virology data
/datum/config_entry/flag/log_virus

/// log cloning actions.
/datum/config_entry/flag/log_cloning

/// log assets
/datum/config_entry/flag/log_asset

/// log voting
/datum/config_entry/flag/log_vote

/// log client whisper
/datum/config_entry/flag/log_whisper

/// log attack messages
/datum/config_entry/flag/log_attack

/// log emotes
/datum/config_entry/flag/log_emote

/// log economy actions
/datum/config_entry/flag/log_econ

/// log traitor objectives
/datum/config_entry/flag/log_traitor

/// log admin chat messages
/datum/config_entry/flag/log_adminchat
	protection = CONFIG_ENTRY_LOCKED

/// log pda messages
/datum/config_entry/flag/log_pda

/// log uplink/spellbook/codex ciatrix purchases and refunds
/datum/config_entry/flag/log_uplink

/// log telecomms messages
/datum/config_entry/flag/log_telecomms

/// log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.
/datum/config_entry/flag/log_twitter

/// log all world.Topic() calls
/datum/config_entry/flag/log_world_topic

/// log crew manifest to separate file
/datum/config_entry/flag/log_manifest

/// log roundstart divide occupations debug information to a file
/datum/config_entry/flag/log_job_debug

/// log shuttle related actions, ie shuttle computers, shuttle manipulator, emergency console
/datum/config_entry/flag/log_shuttle

/// logs all timers in buckets on automatic bucket reset (Useful for timer debugging)
/datum/config_entry/flag/log_timers_on_bucket_reset

/// allows admins with relevant permissions to have their own ooc colour
/datum/config_entry/flag/allow_admin_ooccolor

/// allows admins with relevant permissions to have a personalized asay color
/datum/config_entry/flag/allow_admin_asaycolor

/// allow votes to restart
/datum/config_entry/flag/allow_vote_restart

/// allow votes to change map
/datum/config_entry/flag/allow_vote_map

/// minimum time between voting sessions (deciseconds, 10 minute default)
/datum/config_entry/number/vote_delay
	default = 6000
	integer = FALSE
	min_val = 0

/// length of voting period (deciseconds, default 1 minute)
/datum/config_entry/number/vote_period
	default = 600
	integer = FALSE
	min_val = 0

/// vote does not default to nochange/norestart.
/datum/config_entry/flag/default_no_vote

/// Prevents dead people from voting.
/datum/config_entry/flag/no_dead_vote

/// Gives the ability to send players a maptext popup.
/datum/config_entry/flag/popup_admin_pm

/datum/config_entry/number/fps
	default = 20
	integer = FALSE
	min_val = 1
	max_val = 100 //byond will start crapping out at 50, so this is just ridic
	var/sync_validate = FALSE

/datum/config_entry/number/fps/ValidateAndSet(str_val)
	. = ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/ticklag/TL = config.entries_by_type[/datum/config_entry/number/ticklag]
		if(!TL.sync_validate)
			TL.ValidateAndSet(10 / config_entry_value)
		sync_validate = FALSE

/datum/config_entry/number/ticklag
	integer = FALSE
	var/sync_validate = FALSE

/datum/config_entry/number/ticklag/New() //ticklag weirdly just mirrors fps
	var/datum/config_entry/CE = /datum/config_entry/number/fps
	default = 10 / initial(CE.default)
	..()

/datum/config_entry/number/ticklag/ValidateAndSet(str_val)
	. = text2num(str_val) > 0 && ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/fps/FPS = config.entries_by_type[/datum/config_entry/number/fps]
		if(!FPS.sync_validate)
			FPS.ValidateAndSet(10 / config_entry_value)
		sync_validate = FALSE

/datum/config_entry/flag/allow_holidays

/datum/config_entry/flag/admin_legacy_system //Defines whether the server uses the legacy admin system with admins.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/protect_legacy_admins //Stops any admins loaded by the legacy system from having their rank edited by the permissions panel
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/protect_legacy_ranks //Stops any ranks loaded by the legacy system from having their flags edited by the permissions panel
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/enable_localhost_rank //Gives the !localhost! rank to any client connecting from 127.0.0.1 or ::1
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/load_legacy_ranks_only //Loads admin ranks only from legacy admin_ranks.txt, while enabled ranks are mirrored to the database
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/norespawn

/datum/config_entry/flag/usewhitelist

/datum/config_entry/flag/use_age_restriction_for_jobs //Do jobs use account age restrictions? --requires database

/datum/config_entry/flag/use_account_age_for_jobs //Uses the time they made the account for the job restriction stuff. New player joining alerts should be unaffected.

/datum/config_entry/flag/use_exp_tracking

/// Enables head jobs time restrictions.
/datum/config_entry/flag/use_exp_restrictions_heads

/datum/config_entry/number/use_exp_restrictions_heads_hours
	default = 0
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/use_exp_restrictions_heads_department

/// Enables non-head jobs time restrictions.
/datum/config_entry/flag/use_exp_restrictions_other

/datum/config_entry/flag/use_exp_restrictions_admin_bypass

/datum/config_entry/flag/use_low_living_hour_intern

/datum/config_entry/number/use_low_living_hour_intern_hours
	default = 0
	integer = FALSE
	min_val = 0

/datum/config_entry/string/server

/datum/config_entry/string/banappeals

/datum/config_entry/string/wikiurl
	default = "https://daedalus13.net/"

/datum/config_entry/string/forumurl
	default = "https://daedalus13.net/" /// Until we actually get a forum, we will use this as a placeholder.

/datum/config_entry/string/rulesurl
	default = "https://daedalus13.net/"

/datum/config_entry/string/githuburl
	default = "https://github.com/DaedalusDock/Gameserver"

/datum/config_entry/string/discordbotcommandprefix
	default = "?"

/datum/config_entry/string/panic_bunker_discord_link

/datum/config_entry/string/roundstatsurl

/datum/config_entry/string/gamelogurl

/datum/config_entry/flag/guest_ban

/datum/config_entry/number/id_console_jobslot_delay
	default = 30
	integer = FALSE
	min_val = 0

/datum/config_entry/number/inactivity_period //time in ds until a player is considered inactive
	default = 3000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/inactivity_period/ValidateAndSet(str_val)
	. = ..()
	if(.)
		config_entry_value *= 10 //documented as seconds in config.txt

/datum/config_entry/number/afk_period //time in ds until a player is considered inactive
	default = 3000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/afk_period/ValidateAndSet(str_val)
	. = ..()
	if(.)
		config_entry_value *= 10 //documented as seconds in config.txt

/datum/config_entry/flag/kick_inactive //force disconnect for inactive players

/datum/config_entry/flag/forbid_singulo_possession

/datum/config_entry/flag/automute_on //enables automuting/spam prevention

/datum/config_entry/string/panic_server_name

/datum/config_entry/string/panic_server_name/ValidateAndSet(str_val)
	return str_val != "\[Put the name here\]" && ..()

/datum/config_entry/string/panic_server_address //Reconnect a player this linked server if this server isn't accepting new players

/datum/config_entry/string/panic_server_address/ValidateAndSet(str_val)
	return str_val != "byond://address:port" && ..()

/datum/config_entry/string/invoke_youtubedl
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/flag/show_irc_name

/datum/config_entry/flag/see_own_notes //Can players see their own admin notes

/datum/config_entry/number/note_fresh_days
	default = null
	min_val = 0
	integer = FALSE

/datum/config_entry/number/note_stale_days
	default = null
	min_val = 0
	integer = FALSE

/datum/config_entry/flag/maprotation

/datum/config_entry/number/auto_lag_switch_pop //Number of clients at which drastic lag mitigation measures kick in
	config_entry_value = null
	min_val = 0

/datum/config_entry/number/soft_popcap
	default = null
	min_val = 0

/datum/config_entry/number/hard_popcap
	default = null
	min_val = 0

/datum/config_entry/number/extreme_popcap
	default = null
	min_val = 0

/datum/config_entry/string/soft_popcap_message
	default = "Be warned that the server is currently serving a high number of users, consider using alternative game servers."

/datum/config_entry/string/hard_popcap_message
	default = "The server is currently serving a high number of users, You cannot currently join. You may wait for the number of living crew to decline, observe, or find alternative servers."

/datum/config_entry/string/extreme_popcap_message
	default = "The server is currently serving a high number of users, find alternative servers."

/datum/config_entry/flag/byond_member_bypass_popcap

/datum/config_entry/flag/panic_bunker // prevents people the server hasn't seen before from connecting

/datum/config_entry/number/panic_bunker_living // living time in minutes that a player needs to pass the panic bunker
	min_val = -1
	default = -1

/// Flag for requiring players who would otherwise be denied access by the panic bunker to complete a written interview
/datum/config_entry/flag/panic_bunker_interview

/// Flag to enable the whitelist, only allowing registered players to enter the server
/datum/config_entry/flag/panic_bunker_discord_require

/datum/config_entry/string/panic_bunker_message
	default = "Sorry but the server is currently not accepting connections from never before seen players."

/datum/config_entry/number/notify_new_player_age // how long do we notify admins of a new player
	min_val = -1

/datum/config_entry/number/notify_new_player_account_age // how long do we notify admins of a new byond account
	min_val = 0

/datum/config_entry/flag/irc_first_connection_alert // do we notify the irc channel when somebody is connecting for the first time?

/datum/config_entry/string/ipintel_email

/datum/config_entry/string/ipintel_email/ValidateAndSet(str_val)
	return str_val != "ch@nge.me" && ..()

/datum/config_entry/number/ipintel_rating_bad
	default = 1
	integer = FALSE
	min_val = 0
	max_val = 1

/datum/config_entry/number/ipintel_save_good
	default = 12
	integer = FALSE
	min_val = 0

/datum/config_entry/number/ipintel_save_bad
	default = 1
	integer = FALSE
	min_val = 0

/datum/config_entry/string/ipintel_domain
	default = "check.getipintel.net"

/datum/config_entry/flag/aggressive_changelog

/datum/config_entry/flag/autoconvert_notes //if all connecting player's notes should attempt to be converted to the database
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/allow_webclient

/datum/config_entry/flag/webclient_only_byond_members

/datum/config_entry/flag/announce_admin_logout

/datum/config_entry/flag/announce_admin_login

/datum/config_entry/flag/allow_map_voting
	deprecated_by = /datum/config_entry/flag/preference_map_voting

/datum/config_entry/flag/allow_map_voting/DeprecationUpdate(value)
	return value

/datum/config_entry/flag/preference_map_voting

/datum/config_entry/number/client_warn_version
	default = null
	min_val = 500

/datum/config_entry/number/client_warn_build
	default = null
	min_val = 0

/datum/config_entry/string/client_warn_message
	default = "Your version of byond may have issues or be blocked from accessing this server in the future."

/datum/config_entry/flag/client_warn_popup

/datum/config_entry/number/client_error_version
	default = null
	min_val = 500

/datum/config_entry/string/client_error_message
	default = "Your version of byond is too old, may have issues, and is blocked from accessing this server."

/datum/config_entry/number/client_error_build
	default = null
	min_val = 0

/datum/config_entry/number/minute_topic_limit
	default = null
	min_val = 0

/datum/config_entry/number/second_topic_limit
	default = null
	min_val = 0

/datum/config_entry/number/minute_click_limit
	default = 400
	min_val = 0

/datum/config_entry/number/second_click_limit
	default = 15
	min_val = 0

/datum/config_entry/number/error_cooldown // The "cooldown" time for each occurrence of a unique error
	default = 600
	integer = FALSE
	min_val = 0

/datum/config_entry/number/error_limit // How many occurrences before the next will silence them
	default = 50

/datum/config_entry/number/error_silence_time // How long a unique error will be silenced for
	default = 6000
	integer = FALSE

/datum/config_entry/number/error_msg_delay // How long to wait between messaging admins about occurrences of a unique error
	default = 50
	integer = FALSE

/datum/config_entry/flag/irc_announce_new_game
	deprecated_by = /datum/config_entry/string/chat_announce_new_game

/datum/config_entry/flag/irc_announce_new_game/DeprecationUpdate(value)
	return "" //default broadcast

/datum/config_entry/string/chat_announce_new_game
	default = null

/datum/config_entry/string/chat_newgame_staple
	default = null

/datum/config_entry/flag/debug_admin_hrefs

/datum/config_entry/number/mc_tick_rate/base_mc_tick_rate
	integer = FALSE
	default = 1

/datum/config_entry/number/mc_tick_rate/high_pop_mc_tick_rate
	integer = FALSE
	default = 1.1

/datum/config_entry/number/mc_tick_rate/high_pop_mc_mode_amount
	default = 65

/datum/config_entry/number/mc_tick_rate/disable_high_pop_mc_mode_amount
	default = 60

/datum/config_entry/number/mc_tick_rate
	abstract_type = /datum/config_entry/number/mc_tick_rate

/datum/config_entry/number/mc_tick_rate/ValidateAndSet(str_val)
	. = ..()
	if (.)
		Master.UpdateTickRate()

/datum/config_entry/flag/resume_after_initializations

/datum/config_entry/flag/resume_after_initializations/ValidateAndSet(str_val)
	. = ..()
	if(. && MC_RUNNING())
		world.sleep_offline = !config_entry_value

/datum/config_entry/number/rounds_until_hard_restart
	default = -1
	min_val = 0

/datum/config_entry/string/default_view
	default = "15x15"

/datum/config_entry/string/default_view_square
	default = "15x15"

/datum/config_entry/flag/log_pictures

/datum/config_entry/flag/picture_logging_camera


/datum/config_entry/flag/reopen_roundstart_suicide_roles

/datum/config_entry/flag/reopen_roundstart_suicide_roles_command_positions

/datum/config_entry/number/reopen_roundstart_suicide_roles_delay
	min_val = 30

/datum/config_entry/flag/reopen_roundstart_suicide_roles_command_report

/datum/config_entry/flag/auto_profile

/datum/config_entry/number/drift_dump_threshold
	default = 4 SECONDS

/datum/config_entry/number/drift_profile_delay
	default = 15 SECONDS

/datum/config_entry/string/centcom_ban_db // URL for the CentCom Galactic Ban DB API

/datum/config_entry/string/centcom_source_whitelist

/// URL for admins to be redirected to for 2FA
/datum/config_entry/string/admin_2fa_url

/datum/config_entry/number/hard_deletes_overrun_threshold
	integer = FALSE
	min_val = 0
	default = 0.5

/datum/config_entry/number/hard_deletes_overrun_limit
	default = 0
	min_val = 0

/datum/config_entry/str_list/motd

/datum/config_entry/number/urgent_ahelp_cooldown
	default = 300

/datum/config_entry/string/urgent_ahelp_message
	default = "This ahelp is urgent!"

/datum/config_entry/string/ahelp_message
	default = ""

/datum/config_entry/string/urgent_ahelp_user_prompt
	default = "There are no admins currently on. Do not press the button below if your ahelp is a joke, a request or a question. Use it only for cases of obvious grief."

/datum/config_entry/string/urgent_adminhelp_webhook_url

/datum/config_entry/string/regular_adminhelp_webhook_url

/datum/config_entry/string/adminhelp_webhook_pfp

/datum/config_entry/string/adminhelp_webhook_name

/datum/config_entry/string/adminhelp_ahelp_link

/datum/config_entry/flag/cache_assets
	default = TRUE

/datum/config_entry/flag/station_name_in_hub_entry
	default = FALSE

/datum/config_entry/number/pr_announcements_per_round
	default = 5
	min_val = 0
	integer = TRUE

/datum/config_entry/flag/forbid_all_profiling

/datum/config_entry/flag/forbid_admin_profiling

//Fail2Topic settings.
/datum/config_entry/number/topic_rate_limit
	config_entry_value = 5
	min_val = 1
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/number/topic_max_fails
	config_entry_value = 5
	min_val = 1
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/topic_rule_name
	config_entry_value = "_DD_Fail2topic"
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/number/topic_max_size
	config_entry_value = 500
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/topic_enabled
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/show_job_estimation

/// Unique slug for the webmap
/datum/config_entry/string/webmap_community
	default = "DaedalusDock"
