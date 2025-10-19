return {
	"otavioschwanck/arrow.nvim",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
		-- { "echasnovski/mini.icons" },
	},
	event = "VeryLazy",
	opts = {
		-- Pick keys that don't shadow important Vim defaults (Norwegian-friendly)
		-- Avoid: ';' (f/t repeat), 'm' (marks), '.' (repeat), 'o'/'O', 'q', etc.
		leader_key = 'ø',  -- global Arrow prefix
		buffer_leader_key = 'å', -- per-buffer Arrow prefix

		show_icons = true,
		always_show_path = false,
		separate_by_branch = false,
		hide_handbook = false,
		hide_buffer_handbook = false,

		save_path = function()
			return vim.fn.stdpath("cache") .. "/arrow"
		end,

		-- Menu mappings (inside Arrow UI). Use easy, ASCII-only keys.
		mappings = {
			edit = "e",
			delete_mode = "d",
			clear_all_items = "C",
			toggle = "s",
			open_vertical = "v",
			open_horizontal = "h",
			quit = "q",
			remove = "x",
			next_item = "j",
			prev_item = "k",
		},

		custom_actions = {
			open = function(target_file_name, current_file_name) end,
			split_vertical = function(target_file_name, current_file_name) end,
			split_horizontal = function(target_file_name, current_file_name) end,
		},

		window = {
			width = "auto",
			height = "auto",
			row = "auto",
			col = "auto",
		},

		per_buffer_config = {
			lines = 4,
			sort_automatically = true,
			satellite = { enable = false, overlap = true, priority = 1000 },
			zindex = 10,
			treesitter_context = nil,
		},

		separate_save_and_remove = false,
		save_key = "cwd",
		global_bookmarks = false,

		-- Keep to simple digits+letters reachable on Norwegian layout
		index_keys = "1234567890asdfghjklqwertyuiopzxcvbnm",

		full_path_list = { "update_stuff" },
	},
	config = function(_, opts)
		require('arrow').setup(opts)
	end,
}
