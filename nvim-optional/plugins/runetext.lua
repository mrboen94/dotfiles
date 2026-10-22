return {
	dir = "~/Documents/projects/runic/helrune/editor/nvim",
	ft = "runetext",
	config = function()
		require("runetext").setup({
			-- viewer = "open",  -- if you don't have zathura
			-- image_split_cmd = "botright vsplit",
			-- image_window_width = 90,
			-- image_max_width_window_percentage = 98,
			-- image_max_height_window_percentage = 98,
			-- follow_cursor_page = true,

			pdf_backend = "doctor-norse",
			doctor_norse_bin = "/Users/mathiasboe/Documents/projects/agentic-development/apps/doctor-norse/doctor-norse",
			preview_mode = "zathura", -- default mode; use command to switch per-session

			-- image_follow_cursor_on_move = true,
			-- image_cursor_move_debounce_ms = 10,
			-- image_ignore_partial_updates = false,
			-- image_same_page_throttle_ms = 0,
			-- image_rerender_on_same_path = true,
			-- image_inline = true,
			-- image_with_virtual_padding = false,
			-- server_cmd = {
			-- "node",
			-- "/Users/mathiasboe/Documents/projects/runic/helrune/dist/preview-server.js",
			-- },
		})
	end,
}
