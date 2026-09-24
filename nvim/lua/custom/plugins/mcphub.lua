return {
	'ravitemer/mcphub.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	cmd = 'MCPHub',
	build = 'bundled_build.lua', -- installs the mcp-hub binary locally, no global npm needed
	keys = {
		{ '<leader>am', '<cmd>MCPHub<CR>', desc = 'MCP Hub' },
	},
	config = function()
		require('mcphub').setup {
			use_bundled_binary = true,
			extensions = {
				avante = {
					make_slash_commands = true, -- expose MCP server prompts as /mcp:server:prompt
				},
			},
		}
	end,
}
