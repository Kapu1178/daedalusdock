/// Ensure that anonymous themes works without changing your preferences
/datum/unit_test/arm_fingerprints
	name = "Arms Shall Inherit Fingerprints"

/datum/unit_test/arm_fingerprints/Run()
	var/mob/living/carbon/human/dummy = allocate(__IMPLIED_TYPE__)

	var/obj/item/bodypart/arm/arm = dummy.get_bodypart(BODY_ZONE_L_ARM)

	TEST_ASSERT(md5(dummy.dna.unique_identity) == arm.fingerprints, "Arm fingerprint does not match DNA fingerprint.")
