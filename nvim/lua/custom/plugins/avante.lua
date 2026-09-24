return {
	'yetone/avante.nvim',
	event = 'VeryLazy',
	version = false, -- always pull latest
	build = 'bash build.sh', -- downloads prebuilt binaries, no rust/cargo needed
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
		'nvim-tree/nvim-web-devicons',
		'folke/snacks.nvim', -- input/picker provider
		{
			-- Render avante's markdown responses
			'MeanderingProgrammer/render-markdown.nvim',
			opts = { file_types = { 'markdown', 'Avante' } },
			ft = { 'markdown', 'Avante' },
		},
		{
			-- Paste images into the chat
			'HakonHarnes/img-clip.nvim',
			event = 'VeryLazy',
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = { insert_mode = true },
				},
			},
		},
		'ravitemer/mcphub.nvim', -- MCP tools for avante
	},
	keys = {
		{ '<leader>at', '<cmd>AvanteToggle<CR>', desc = 'Toggle avante' },
	},
	opts = {
		provider = 'claude',
		input = { provider = 'snacks' },
		-- Use mcphub's prompt and tools instead of avante's built-in MCP tool handling
		system_prompt = function()
			local ok, hub = pcall(function() return require('mcphub').get_hub_instance() end)
			return ok and hub and hub:get_active_servers_prompt() or ''
		end,
		custom_tools = function()
			return { require('mcphub.extensions.avante').mcp_tool() }
		end,
		-- Disable built-in tools that mcphub servers replace
		disabled_tools = {
			'list_files',
			'search_files',
			'read_file',
			'create_file',
			'rename_file',
			'delete_file',
			'create_dir',
			'rename_dir',
			'delete_dir',
			'bash',
		},
	},
}
