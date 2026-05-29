// This test is for testing that items created with designs from a fabricator do not result in a net gain in materials.
// This test does NOT account for material categories or materials becoming other materials, such as being able to transmute Iron to Glass.
/datum/unit_test/infinite_materials
	name = "MATERIALS/DESIGNS: Printable Items Shall Not Grant More Materials Than Cost"

/datum/unit_test/infinite_materials/Run()
	for(var/datum/design/design as anything in SStech.designs)
		if(isabstract(design))
			continue

		var/object_path = design.build_path
		if(isnull(object_path))
			TEST_FAIL("Non-abstract design [design.type] has no build path.")
			continue

		var/obj/item/built = new object_path(run_loc_floor_bottom_left)
		var/list/item_materials = built.get_material_composition()

		for(var/material_or_text, cost in design.materials)
			if(!istext(material_or_text))
				var/datum/material/material = material_or_text
				if(item_materials[material_or_text] > cost)
					TEST_FAIL("Design [design.type]'s product has more [material.id] than it costs.")

		qdel(built)
