return {
	dir = vim.fn.stdpath('config') .. '/lua/custom/nvim-dap-odin',
	name = 'nvim-dap-odin',
	dependencies = { 'mfussenegger/nvim-dap' },
	config = function()
		require('custom.nvim-dap-odin').setup()
	end,
}
