vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

return {
	'nvim-neo-tree/neo-tree.nvim',
	version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
		'MunifTanjim/nui.nvim',
	},
	lazy = false, -- Keeping lazy = false as it's in the first config. If you want lazy loading, set it to true and ensure you have a way to trigger it (e.g., an autocommand or a specific command).
	keys = {
		{ "'", ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
		-- The '\\' mapping in the second config's window mappings is specific to the Neo-tree window itself.
		-- The global keybinding here makes more sense for revealing the current file in Neo-tree from anywhere.
	},
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
