return {
	"3rd/image.nvim",
	build = false,
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		backend = "kitty", -- first try this in WezTerm
		processor = "magick_cli",
		integrations = {
			markdown = {
				enabled = true,
				only_render_image_at_cursor = true,
				only_render_image_at_cursor_mode = "popup",
			},
		},
	},
}
