/// Called whenever a mob should be resized or for standing/lying up.
/mob/living/proc/update_transform(resize = RESIZE_DEFAULT_SIZE)
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/final_pixel_y = base_pixel_y + body_position_pixel_y_offset
	/**
	 * pixel x/y/w/z all discard values after the decimal separator.
	 * That, coupled with the rendered interpolation, may make the
	 * icons look awfuller than they already are, or not, whatever.
	 * The solution to this nit is translating the missing decimals.
	 * also flooring increases the distance from 0 for negative numbers.
	 */
	var/abs_pixel_y_offset = 0
	var/translate = 0

	if(current_size != RESIZE_DEFAULT_SIZE)
		var/standing_offset = get_pixel_y_offset_standing(current_size)
		abs_pixel_y_offset = abs(standing_offset)
		translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(standing_offset)

	var/final_dir = dir
	var/changed = FALSE

	if(lying_angle != lying_prev && rotate_on_lying)
		changed = TRUE
		if(lying_angle && lying_prev == 0)
			if(translate)
				ntransform.Translate(0, -translate)
			if(dir & (EAST|WEST)) //Standing to lying and facing east or west
				final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

		else if(translate && !lying_angle && lying_prev != 0)
			ntransform.Translate(translate * (lying_prev == 270 ? -1 : 1), 0)

		///Done last, as it can mess with the translation.
		ntransform.TurnTo(lying_prev, lying_angle)

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		var/is_vertical = !lying_angle || !rotate_on_lying

		///scaling also affects translation, so we've to undo the old translate beforehand.
		if(translate && is_vertical)
			ntransform.Translate(0, -translate)

		ntransform.Scale(resize)
		current_size *= resize

		//Update the height of the maptext according to the size of the mob so they don't overlap.
		var/old_maptext_offset = body_maptext_height_offset
		body_maptext_height_offset = initial(maptext_height) * (current_size - 1) * 0.5
		maptext_height += body_maptext_height_offset - old_maptext_offset

		//Update final_pixel_y so our mob doesn't go out of the southern bounds of the tile when standing
		if(is_vertical) //But not if the mob has been rotated.
			//Make sure the body position y offset is also updated
			body_position_pixel_y_offset = get_pixel_y_offset_standing(current_size)
			abs_pixel_y_offset = abs(body_position_pixel_y_offset)
			var/new_translate = (abs_pixel_y_offset - round(abs_pixel_y_offset)) * SIGN(body_position_pixel_y_offset)
			if(new_translate)
				ntransform.Translate(0, new_translate)
			final_pixel_y = base_pixel_y + body_position_pixel_y_offset

	if(!changed) //Nothing has been changed, nothing has to be done.
		return FALSE

	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, UPDATE_TRANSFORM_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_NO_FLOATING_ANIM, UPDATE_TRANSFORM_TRAIT), 0.3 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	//if true, we want to avoid any animation time, it'll tween and not rotate at all otherwise.
	var/is_opposite_angle = SIMPLIFY_DEGREES(lying_angle+180) == lying_prev
	z_animate(src, transform = ntransform, time = is_opposite_angle ? 0 : 0.2 SECONDS, pixel_y = final_pixel_y, dir = final_dir, easing = (EASE_IN|EASE_OUT))

	update_hud_images_height()

	SEND_SIGNAL(src, COMSIG_MOB_POST_UPDATE_TRANSFORM, resize, lying_angle, is_opposite_angle) // ...and we want the signal to be sent last.
	return changed

/mob/living/get_offsets()
	. += ..()

	for(var/offset_key in LAZYACCESS(offsets, PIXEL_X_OFFSET))
		.[PIXEL_X_OFFSET] += offsets[PIXEL_X_OFFSET][offset_key]
	for(var/offset_key in LAZYACCESS(offsets, PIXEL_Y_OFFSET))
		.[PIXEL_Y_OFFSET] += offsets[PIXEL_Y_OFFSET][offset_key]

/**
 * Adds an offset to the mob's pixel position.
 *
 * * source: The source of the offset, a string
 * * w_add: pixel_w offset
 * * x_add: pixel_x offset
 * * y_add: pixel_y offset
 * * z_add: pixel_z offset
 * * animate: If TRUE, the mob will animate to the new position. If FALSE, it will instantly move.
 */
/mob/living/proc/add_offsets(source, w_add, x_add, y_add, z_add, animate = TRUE)
	LAZYINITLIST(offsets)
	if(isnum(x_add))
		LAZYSET(offsets[PIXEL_X_OFFSET], source, x_add)
	if(isnum(y_add))
		LAZYSET(offsets[PIXEL_Y_OFFSET], source, y_add)
	update_offsets(animate)

/**
 * Goes through all pixel adjustments and removes any tied to the passed source.
 *
 * * source: The source of the offset to remove
 * * animate: If TRUE, the mob will animate to the position with any offsets removed. If FALSE, it will instantly move.
 */
/mob/living/proc/remove_offsets(source, animate = TRUE)
	for(var/offset in offsets)
		LAZYREMOVE(offsets[offset], source)
		ASSOC_UNSETEMPTY(offsets, offset)

	UNSETEMPTY(offsets)
	update_offsets(animate)

/**
 * Checks if we are offset by the passed source for the passed pixel.
 *
 * * source: The source of the offset
 * If not supplied, it will report the total offset of the passed pixel.
 * * pixel: Optional, The pixel to check.
 * If not supplied, just reports if it's offset by the source at all (returning the first offset found).
 *
 * Returns the offset if we are, 0 otherwise.
 */
/mob/living/proc/has_offset(source, pixel)
	if(isnull(source) && isnull(pixel))
		stack_trace("has_offset() requires at least one argument.")
		return 0

	if(isnull(source))
		if(!length(offsets?[pixel]))
			return 0

		var/total_found_offset = 0
		for(var/found_offset in offsets[pixel])
			total_found_offset += has_offset(found_offset, pixel)
		return total_found_offset

	if(isnull(pixel))
		for(var/found_pixel in offsets)
			var/found_offset = has_offset(source, found_pixel)
			if(found_offset)
				return found_offset

		return 0

	return offsets?[pixel]?[source] || 0

/mob/living/set_base_pixel_x(new_value)
	. = ..()
	update_offsets(FALSE)

/mob/living/set_base_pixel_y(new_value)
	. = ..()
	update_offsets(FALSE)
