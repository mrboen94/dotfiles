return {
	'sphamba/smear-cursor.nvim',
	opts = {
		stiffness = 0.5,                -- 0.6      [0, 1]
		trailing_stiffness = 0.3,       -- 0.45     [0, 1]
		stiffness_insert_mode = 0.4,    -- 0.5      [0, 1]
		trailing_stiffness_insert_mode = 0.4, -- 0.5      [0, 1]
		damping = 0.85,                 -- 0.85     [0, 1]
		damping_insert_mode = 0.85,     -- 0.9      [0, 1]
		distance_stop_animating = 0.9,  -- 0.1      > 0
		smear_between_neighbor_lines = true,
		-- cursor_color = "#ffffff00",
		never_draw_over_target = true,
		gamma = 1,
		hide_target_hack = true,
		time_interval = 7,
	},
}
