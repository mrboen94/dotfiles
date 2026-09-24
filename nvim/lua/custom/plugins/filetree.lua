vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

return {
	'nvim-neo-tree/neo-tree.nvim',
	enabled = false, -- replaced by the snacks explorer (see snacks.lua); config kept for reference
	version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
		'MunifTanjim/nui.nvim',
	},
	lazy = false, -- Keeping lazy = false as it's in the first config. If you want lazy loading, set it to true and ensure you have a way to trigger it (e.g., an autocommand or a specific command).
	-- Keymaps moved to snacks.lua ('|' on Linux / "'" on macOS to reveal, <leader>tt to toggle)
	config = function()
		require('neo-tree').setup {
			close_if_last_window = true,
			popup_border_style = 'single',
			enable_git_status = true,
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = 'NeoTreeFileName',
			},
			git_status = {
				symbols = {
					-- Change type
					added = '',
					modified = '',
					deleted = '✖',
					renamed = '󰁕',
					-- Status type
					untracked = '',
					ignored = '',
					unstaged = '󰄱',
					staged = '',
					conflict = '',
				},
			},
			filesystem = {
				filtered_items = {
					visible = true, -- Hidden files
					hide_dotfiles = false,
				},

				window = {
					position = 'right',
					width = 30,
					mapping_options = {
						noremap = true,
						nowait = true,
					},
					mappings = {
						['<space>'] = {
							'toggle_node',
							nowait = false,
						},
						['<2-LeftMouse>'] = 'open',
						['<cr>'] = 'open',
						['<esc>'] = 'cancel',
						['P'] = { 'toggle_preview', config = { use_float = true, use_image_nvim = true } },
						['l'] = 'focus_preview',
						['S'] = 'open_split',
						['s'] = 'open_vsplit',
						['t'] = 'open_tabnew',
						['C'] = 'close_node',
						['z'] = 'close_all_nodes',
						['a'] = {
							'add',
							config = {
								show_path = 'none',
							},
						},
						['A'] = 'add_directory',
						['d'] = 'delete',
						['r'] = 'rename',
						['y'] = 'copy_to_clipboard',
						['x'] = 'cut_to_clipboard',
						['p'] = 'paste_from_clipboard',
						['c'] = 'copy',
						['m'] = 'move',
						['q'] = 'close_window',
						-- The following mapping from your first config is now redundant as 'q' is already mapped to 'close_window'
						-- ['\\'] = 'close_window',
						['R'] = 'refresh',
						['?'] = 'show_help',
						['<'] = 'prev_source',
						['>'] = 'next_source',
						['i'] = 'show_file_details',
					},
				},
			},
		}
	end,
}
