/// Trim for basic Centcom cards.
/datum/access_template/centcom
	access = list(ACCESS_CENT_GENERAL)
	assignment = JOB_CENTCOM
	template_state = "trim_centcom"
	sechud_icon_state = SECHUD_CENTCOM

/// Trim for Centcom VIPs
/datum/access_template/centcom/vip
	access = list(ACCESS_CENT_GENERAL)
	assignment = JOB_CENTCOM_VIP

/// Trim for Centcom Custodians.
/datum/access_template/centcom/custodian
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	assignment = JOB_CENTCOM_CUSTODIAN

/// Trim for Centcom Thunderdome Overseers.
/datum/access_template/centcom/thunderdome_overseer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
	assignment = JOB_CENTCOM_THUNDERDOME_OVERSEER

/// Trim for Centcom Officials.
/datum/access_template/centcom/official
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = JOB_CENTCOM_OFFICIAL

/// Trim for Centcom Interns.
/datum/access_template/centcom/intern
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = "CentCom Intern"

/// Trim for Centcom Head Interns. Different assignment, common station access added on.
/datum/access_template/centcom/intern/head
	assignment = "CentCom Head Intern"

/datum/access_template/centcom/intern/head/New()
	. = ..()
	access |= SSid_access.get_access_for_group(/datum/access_group/station/common_areas)

/// Trim for Bounty Hunters hired by centcom.
/datum/access_template/centcom/bounty_hunter
	access = list(ACCESS_CENT_GENERAL)
	assignment = "Bounty Hunter"

/// Trim for Centcom Bartenders.
/datum/access_template/centcom/bartender
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
	assignment = JOB_CENTCOM_BARTENDER

/// Trim for Centcom Medical Officers.
/datum/access_template/centcom/medical_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
	assignment = JOB_CENTCOM_MEDICAL_DOCTOR

/// Trim for Centcom Research Officers.
/datum/access_template/centcom/research_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
	assignment = JOB_CENTCOM_RESEARCH_OFFICER

/// Trim for Centcom Specops Officers. All Centcom and Station Access.
/datum/access_template/centcom/specops_officer
	assignment = JOB_CENTCOM_SPECIAL_OFFICER

/datum/access_template/centcom/specops_officer/New()
	. = ..()

	access = SSid_access.get_access_for_group(list(/datum/access_group/centcom, /datum/access_group/station/all))

/// Trim for Centcom (Soviet) Admirals. All Centcom and Station Access.
/datum/access_template/centcom/admiral
	assignment = JOB_CENTCOM_ADMIRAL

/datum/access_template/centcom/admiral/New()
	. = ..()

	access = SSid_access.get_access_for_group(list(/datum/access_group/centcom, /datum/access_group/station/all))

/// Trim for Centcom Commanders. All Centcom and Station Access.
/datum/access_template/centcom/commander
	assignment = JOB_CENTCOM_COMMANDER

/datum/access_template/centcom/commander/New()
	. = ..()

	access = SSid_access.get_access_for_group(list(/datum/access_group/centcom, /datum/access_group/station/all))

/// Trim for Deathsquad officers. All Centcom and Station Access.
/datum/access_template/centcom/deathsquad
	assignment = JOB_ERT_DEATHSQUAD
	template_state = "trim_ert_commander"
	sechud_icon_state = SECHUD_DEATH_COMMANDO

/datum/access_template/centcom/deathsquad/New()
	. = ..()

	access = SSid_access.get_access_for_group(list(/datum/access_group/centcom, /datum/access_group/station/all))

/// Trim for generic ERT interns. No universal ID card changing access.
/datum/access_template/centcom/ert
	assignment = "Emergency Response Team Intern"

/datum/access_template/centcom/ert/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)

/// Trim for ERT Commanders. All station and centcom access.
/datum/access_template/centcom/ert/commander
	assignment = JOB_ERT_COMMANDER
	template_state = "trim_ert_commander"
	sechud_icon_state = SECHUD_EMERGENCY_RESPONSE_TEAM_COMMANDER

/datum/access_template/centcom/ert/commander/New()
	. = ..()

	access = SSid_access.get_access_for_group(list(/datum/access_group/centcom, /datum/access_group/station/all))

/// Trim for generic ERT seccies. No universal ID card changing access.
/datum/access_template/centcom/ert/security
	assignment = JOB_ERT_OFFICER
	template_state = "trim_ert_security"
	sechud_icon_state = SECHUD_SECURITY_RESPONSE_OFFICER

/datum/access_template/centcom/ert/security/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT engineers. No universal ID card changing access.
/datum/access_template/centcom/ert/engineer
	assignment = JOB_ERT_ENGINEER
	template_state = "trim_ert_engineering"
	sechud_icon_state = SECHUD_ENGINEERING_RESPONSE_OFFICER

/datum/access_template/centcom/ert/engineer/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT medics. No universal ID card changing access.
/datum/access_template/centcom/ert/medical
	assignment = JOB_ERT_MEDICAL_DOCTOR
	template_state = "trim_ert_medical"
	sechud_icon_state = SECHUD_MEDICAL_RESPONSE_OFFICER

/datum/access_template/centcom/ert/medical/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT chaplains. No universal ID card changing access.
/datum/access_template/centcom/ert/chaplain
	assignment = JOB_ERT_CHAPLAIN
	template_state = "trim_ert_religious"
	sechud_icon_state = SECHUD_RELIGIOUS_RESPONSE_OFFICER

/datum/access_template/centcom/ert/chaplain/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT janitors. No universal ID card changing access.
/datum/access_template/centcom/ert/janitor
	assignment = JOB_ERT_JANITOR
	template_state = "trim_ert_janitor"
	sechud_icon_state = SECHUD_JANITORIAL_RESPONSE_OFFICER

/datum/access_template/centcom/ert/janitor/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)

/// Trim for generic ERT clowns. No universal ID card changing access.
/datum/access_template/centcom/ert/clown
	assignment = JOB_ERT_CLOWN
	template_state = "trim_ert_entertainment"
	sechud_icon_state = SECHUD_ENTERTAINMENT_RESPONSE_OFFICER

/datum/access_template/centcom/ert/clown/New()
	. = ..()

	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING) | (SSid_access.get_access_for_group(list(/datum/access_group/station/all)) - ACCESS_CHANGE_IDS)
