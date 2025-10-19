return {
	'karb94/neoscroll.nvim',
	opts = {
		-- All windows will be scrolled. Set to false to disable.
		all_windows = true,
		-- The animation will be paused for `pause_time` ms after each scroll event.
		pause_time = 10,
		-- The animation will be run for `duration` ms.
		duration = 500,
		-- Only a subset of mappings will be registered, if scrolling has been disabled for the given line count.
		-- Set to 0 to disable.
		max_lines = 5000,
		-- Set to true to use the cursor line to determine scrolling direction instead of the mouse.
		use_cursor_line = false,
		-- Only perform scrolling if the cursor is within the visible screen.
		cursor_scrolls_alone = false,
		-- Enable/disable smooth scrolling for regular movements (not just neoscroll commands)
		default_easing_function = 'quadratic',
		-- Specify a custom easing function for all scrolling movements
		easing = 'quadratic',
		-- Function to run after the scrolling completes
		-- pre_hook = function(info) end,
		-- Function to run before the scrolling starts
		-- post_hook = function(info) end,

		mapping = {
			['<C-u>'] = { 'scroll', { '-vim.wo.scroll', 'true', '100' } },
			['<C-d>'] = { 'scroll', { 'vim.wo.scroll', 'true', '100' } },
			['<C-b>'] = { 'scroll', { '-vim.api.nvim_win_get_height(0)', 'true', '150' } },
			['<C-f>'] = { 'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '150' } },
			['<C-y>'] = { 'scroll', { '-0.10', 'false', '100' } },
			['<C-e>'] = { 'scroll', { '0.10', 'false', '100' } },
			['zt'] = { 'zt', { '100' } },
			['zz'] = { 'zz', { '100' } },
			['zb'] = { 'zb', { '100' } },
		},
	},
}
