return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		picker = {
			enabled = true,
			sources = {
				explorer = {
					layout = { layout = { position = 'right' } }, -- same side neo-tree used
				},
			},
		},
		indent = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		-- Open (revealing the current file) or close the explorer: "'" on macOS, "|" on Linux
		{
			vim.uv.os_uname().sysname == 'Darwin' and "'" or '|',
			function()
				local open = Snacks.picker.get { source = 'explorer' }[1]
				if open then
					open:close()
				else
					Snacks.explorer.reveal()
				end
			end,
			desc = 'Explorer reveal/close',
			silent = true,
		},
		{ '<leader>tt', function() Snacks.explorer() end, desc = 'Toggle explorer' },
	},
}
