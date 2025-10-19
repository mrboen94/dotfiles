-- Custom keymaps configured via lazy.nvim by extending which-key (optional)
return {
	'folke/which-key.nvim',
	optional = true, -- apply even if which-key is disabled
	init = function()
		local map = vim.keymap.set

		-- Neotree toggle and focus
		map('n', '<leader>tt', ':Neotree position=right source=filesystem action=show toggle=true<CR>',
			{ desc = 'Toggle neotree' })

		-- Window management
		-- Basic splits
		map('n', '<leader>wV', ':vsplit<CR>', { desc = 'Vertical split' })
		map('n', '<leader>wH', ':split<CR>', { desc = 'Horizontal split' })

		-- Directional splits (restore <leader>ws{h,j,k,l})
		map('n', '<leader>wsh', ':leftabove vsplit<CR>', { desc = 'Split left' })
		map('n', '<leader>wsl', ':rightbelow vsplit<CR>', { desc = 'Split right' })
		map('n', '<leader>wsj', ':rightbelow split<CR>', { desc = 'Split below' })
		map('n', '<leader>wsk', ':leftabove split<CR>', { desc = 'Split above' })

		-- Go to other window
		map('n', '<leader>ww', '<C-w>w', { desc = 'Goto other window' })

		-- Window movements
		map('n', '<leader>wh', '<C-w>h', { desc = 'Window left' })
		map('n', '<leader>wj', '<C-w>j', { desc = 'Window down' })
		map('n', '<leader>wk', '<C-w>k', { desc = 'Window up' })
		map('n', '<leader>wl', '<C-w>l', { desc = 'Window right' })

		-- Closing/only
		map('n', '<leader>wqq', ':close<CR>', { desc = 'Close current window' })
		map('n', '<leader>wqo', ':only<CR>', { desc = 'Close other windows' })

		-- File/Vim actions
		map('n', '<leader>fs', ':w<CR>', { desc = 'Save file' })
		map('n', '<leader>qs', ':wq<CR>', { desc = 'Save and quit' })
		map('n', '<leader>qq', ':q<CR>', { desc = 'Quit' })
		map('n', '<leader>qf', ':q!<CR>', { desc = 'Force quit' })
		map('n', '<leader>qa', ':qa!<CR>', { desc = 'Quit all (force)' })

		-- Format file using conform.nvim
		map('n', '<C-f>', function()
			require('conform').format { async = true, lsp_format = 'fallback' }
		end, { desc = 'Format file' })
		map('n', '<leader>f<leader>', function()
			require('conform').format { async = true, lsp_format = 'fallback' }
		end, { desc = 'Format file' })

		-- Toggle relative line numbers
		map('n', '<C-l>', ':set invrelativenumber<CR>', { desc = 'Toggle relative line numbers' })

		-- Copy to system clipboard
		map('n', '<C-c>', '"*y', { noremap = true, desc = 'Copy to system clipboard (Normal)' })
		map('v', '<C-c>', '"*y', { noremap = true, desc = 'Copy to system clipboard (Visual)' })

		-- which-key group labels (if which-key active)
		pcall(function()
			local wk = require 'which-key'
			wk.add({
				{ '<leader>w',  group = 'Window' },
				{ '<leader>ws', group = 'Split' },
			})
		end)
	end,
}
