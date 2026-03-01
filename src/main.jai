#import "Basic"; // for print
#import "Math";  // for make translation matrix

#import "GL";
Simp :: #import "Simp";

#import "tbx/engine";   
#import "tbx/time";   
#import "tbx/opengl";   // for buffer object
#import "tbx/geometry"; // for cube

main :: () {
	// This is here because on Windows, segfaults and stuff are silent.
	// If the program ends without printing this message, then something bad happened.
	defer print ("Program ended gracefully, if you stop seeing this then something bad happend.\n");

    wp3 : Windowed_Program_3D;
    wp3.vsync = false;
    wp3.camera_mode = .TWO_DIMENSIONS;
    // wp3.movement_mode = .GOD;
    wp3.window_name = "my_program";
    init(*wp3);

    box_renderable := array_add(*wp3.renderables);

    assign_geometry(box_renderable, create_itpc_with_color_variation(create_box(), .{0.5, 0.5, 0.5}, 0.4));
    buffer_object(*wp3.camera_per_object_transform_color_renderer, box_renderable);

    start_time := current_time_monotonic();

    while !wp3.end_program {
        start_section(*wp3.section_timer, "frame");

        mark_frame_start(*wp3);

        start_section(*wp3.section_timer, "update");
        per_frame_update(*wp3);

        set_local_to_world_matrix(*wp3.camera_per_object_transform_color_renderer, box_renderable.*, make_transform_matrix4(.{1, 1, 0}, .{0, 1, 0}, elapsed_seconds(start_time) * TAU * 0.25));

        end_section(*wp3.section_timer, "update");

        start_section(*wp3.section_timer, "render");
        render_scene(*wp3); 
        end_section(*wp3.section_timer, "render");

        start_section(*wp3.section_timer, "sleep");
        sleep_to_maintain_max_fps(*wp3);
        end_section(*wp3.section_timer, "sleep");

        mark_frame_end(*wp3);

        end_section(*wp3.section_timer, "frame");
    }
}

elapsed_seconds :: (start_time: Apollo_Time) -> float {
    now := current_time_monotonic();
    return cast(float) to_float64_seconds(now - start_time);
}

make_rotation_matrix4 :: (axis: Vector3, angle: float) -> Matrix4 {
    q: Quaternion;
    set_from_axis_and_angle(*q, axis, angle);
    return rotation_matrix(Matrix4, q);
}

make_transform_matrix4 :: (translation: Vector3, rotation_axis: Vector3, rotation_angle: float) -> Matrix4 {
    return make_translation_matrix4(translation) * make_rotation_matrix4(rotation_axis, rotation_angle);
}

