-- This file contains custom keymaps for Neovim.
-- It is loaded via `require('custom.plugins')` in your main init.lua.

return {
  -- Neotree toggle and focus
  vim.keymap.set('n', '<leader>tt', ':Neotree position=right source=filesystem action=show toggle=true<CR>', { desc = 'Toggle neotree' }),

  -- Window management:
  -- Splits:
  vim.keymap.set('n', '<leader>wV', ':vsplit<CR>', { desc = 'Vertical [S]plit' }),
  vim.keymap.set('n', '<leader>wH', ':split<CR>', { desc = 'Horizontal [S]plit' }),
  -- Note: The original config had a duplicated <leader>wsh for "Split left".
  -- Generic vertical/horizontal splits are kept. Directional splits are removed to avoid conflict and redundancy.
  -- You can achieve "split left/right/up/below" by combining splits and window movements if needed.

  -- Go to other window
  vim.keymap.set('n', '<leader>ww', '<C-w>w', { desc = 'Goto other window' }),

  -- Window Movements:
  vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = 'Window left' }),
  vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = 'Window below' }),
  vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = 'Window up' }),
  vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = 'Window right' }),

  -- Opening and quitting
  -- Note: ':c' is for closing the current window in a quickfix list, not a general kill window.
  -- For killing current window, consider `:close` or `:q`.
  vim.keymap.set('n', '<leader>wqq', ':close<CR>', { desc = 'Kill current window' }), -- Changed from :c
  vim.keymap.set('n', '<leader>wqo', ':only<CR>', { desc = 'Kill other windows' }), -- Changed from :on

  -- Vim actions
  vim.keymap.set('n', '<leader>fs', ':w<CR>', { desc = 'Save file' }),
  vim.keymap.set('n', '<leader>qs', ':wq<CR>', { desc = 'Save file and quit' }),
  vim.keymap.set('n', '<leader>qq', ':q<CR>', { desc = 'Quit' }),
  vim.keymap.set('n', '<leader>qf', ':q!<CR>', { desc = 'Force quit vim' }),
  vim.keymap.set('n', '<leader>qa', ':qa!<CR>', { desc = 'Force quit all' }),

  -- Format file using conform.nvim
  vim.keymap.set('n', '<C-f>', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = 'Format file' }),
  vim.keymap.set('n', '<leader>ff', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = 'Format file' }),

  -- Toggle relative line numbers
  vim.keymap.set('n', '<C-l>', ':set invrelativenumber<CR>', { desc = 'Toggle relative line numbers' }),

  -- Copy to clipboard (system clipboard)
  vim.keymap.set('n', '<C-c>', '"*y', { noremap = true, desc = 'Copy to system clipboard (Normal mode)' }), -- Removed <CR>
  vim.keymap.set('v', '<C-c>', '"*y', { noremap = true, desc = 'Copy to system clipboard (Visual mode)' }), -- Removed <CR>
}
