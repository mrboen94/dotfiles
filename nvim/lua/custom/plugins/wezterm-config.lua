return {
	'winter-again/wezterm-config.nvim',
	-- Load lazily and follow the pattern used by other custom plugins
	event = 'VeryLazy',
	-- Plugin options
	opts = {
		append_wezterm_to_rtp = true,
	},
	-- Prepare runtimepath for your custom wezterm folder (like other custom plugins do in init/config blocks)
	init = function()
		local custom_wezterm_dir = vim.fn.expand('/Users/mathiasboe/Documents/projects/dotfiles/wezterm')
		if vim.fn.isdirectory(custom_wezterm_dir .. '/lua') == 1 then
			vim.opt.rtp:append(custom_wezterm_dir)
		end
	end,
	-- Apply setup and expose keymaps via the `keys` field (like other custom plugins)
	config = function(_, opts)
		require('wezterm-config').setup(opts)
	end,
	keys = {
		{
			'<leader>wpr',
			function()
				require('wezterm-config').set_wezterm_user_var('font_size', tostring(18))
			end,
			desc = 'Reset Wezterm Font Size',
		},
		{
			'<leader>wps',
			function()
				vim.ui.input({ prompt = 'Enter font size: ' }, function(input)
					if not input then return end
					local n = tonumber(input)
					if n then
						require('wezterm-config').set_wezterm_user_var('font_size', tostring(n))
						vim.notify('Set Wezterm font size to ' .. n, vim.log.levels.INFO, { title = 'Wezterm Config' })
					else
						vim.notify('Invalid font size input', vim.log.levels.ERROR, { title = 'Wezterm Config' })
					end
				end)
			end,
			desc = 'Set Wezterm Font Size',
		},
		{
			'<leader>wpp',
			function()
				local fonts = { 'PragmataPro Mono Liga', 'Comic Code Ligatures' }
				vim.ui.select(fonts, { prompt = 'Select a font:' }, function(font)
					if font then
						require('wezterm-config').set_wezterm_user_var('font', font)
						vim.notify('Font changed to: ' .. font, vim.log.levels.INFO, { title = 'Wezterm Config' })
					end
				end)
			end,
			desc = 'Change Wezterm Font',
		},
	},
}
