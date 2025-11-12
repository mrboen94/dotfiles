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
		map('n', '<leader>ff', function()
			require('conform').format { async = true, lsp_format = 'fallback' }
		end, { desc = 'Format file' })

		-- Toggle relative line numbers
		map('n', '<C-l>', ':set invrelativenumber<CR>', { desc = 'Toggle relative line numbers' })

		-- Copy to system clipboard
		map('n', '<C-c>', '"*y', { noremap = true, desc = 'Copy to system clipboard (Normal)' })
		map('v', '<C-c>', '"*y', { noremap = true, desc = 'Copy to system clipboard (Visual)' })

		-- Better scrolling - center cursor
		map('n', '<C-d>', '<C-d>zz', { desc = 'Down + center' })
		map('n', '<C-u>', '<C-u>zz', { desc = 'Up + center' })
		map('n', 'n', 'nzzzv', { desc = 'Next + center' })
		map('n', 'N', 'Nzzzv', { desc = 'Prev + center' })

		-- Navigation (non-English keyboard friendly)
		map('n', '<leader>fj', ':cnext<CR>', { desc = 'Next quickfix' })
		map('n', '<leader>fk', ':cprev<CR>', { desc = 'Prev quickfix' })
		map('n', '<leader>fl', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
		map('n', '<leader>fh', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })

		-- Git keymaps
		map('n', '<leader>gb', ':Gitsigns blame_line<CR>', { desc = 'Git blame' })
		map('n', '<leader>gd', ':Gitsigns diffthis<CR>', { desc = 'Git diff' })
		map('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = 'Preview hunk' })
		map('n', '<leader>gh', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
		map('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
		map('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = 'Undo stage' })

		-- Task runner keymaps
		map('n', '<leader>rb', function()
			local cmd
			if vim.fn.filereadable('package.json') == 1 then cmd = 'npm run build'
			elseif vim.fn.filereadable('Cargo.toml') == 1 then cmd = 'cargo build'
			elseif vim.fn.filereadable('Makefile') == 1 or vim.fn.filereadable('makefile') == 1 then cmd = 'make'
			elseif vim.fn.filereadable('go.mod') == 1 then cmd = 'go build'
			elseif vim.fn.glob('*.odin') ~= '' then cmd = 'odin build .'
			else vim.notify('No build config found', vim.log.levels.WARN) return end
			require('overseer').run_template({ name = 'shell', params = { cmd = cmd } })
		end, { desc = 'Build' })

		map('n', '<leader>rr', function()
			local cmd
			if vim.fn.filereadable('package.json') == 1 then cmd = 'npm run dev'
			elseif vim.fn.filereadable('Cargo.toml') == 1 then cmd = 'cargo run'
			elseif vim.fn.filereadable('go.mod') == 1 then cmd = 'go run .'
			elseif vim.bo.filetype == 'python' then cmd = 'python ' .. vim.fn.expand('%')
			elseif vim.fn.glob('*.odin') ~= '' then cmd = 'odin run .'
			else vim.notify('No run config found', vim.log.levels.WARN) return end
			require('overseer').run_template({ name = 'shell', params = { cmd = cmd } })
		end, { desc = 'Run/Dev' })

		map('n', '<leader>rt', function()
			local cmd
			if vim.fn.filereadable('package.json') == 1 then cmd = 'npm test'
			elseif vim.fn.filereadable('Cargo.toml') == 1 then cmd = 'cargo test'
			elseif vim.fn.filereadable('go.mod') == 1 then cmd = 'go test ./...'
			elseif vim.fn.filereadable('pytest.ini') == 1 or vim.fn.filereadable('setup.py') == 1 then cmd = 'pytest'
			elseif vim.fn.glob('*.odin') ~= '' then cmd = 'odin test .'
			else vim.notify('No test config found', vim.log.levels.WARN) return end
			require('overseer').run_template({ name = 'shell', params = { cmd = cmd } })
		end, { desc = 'Test' })

		map('n', '<leader>rl', function()
			local cmd
			if vim.fn.filereadable('package.json') == 1 then cmd = 'npm run lint'
			elseif vim.fn.filereadable('Cargo.toml') == 1 then cmd = 'cargo clippy'
			elseif vim.fn.filereadable('.eslintrc.js') == 1 or vim.fn.filereadable('.eslintrc.json') == 1 then cmd = 'eslint .'
			else vim.notify('No lint config found', vim.log.levels.WARN) return end
			require('overseer').run_template({ name = 'shell', params = { cmd = cmd } })
		end, { desc = 'Lint' })

		map('n', '<leader>ro', '<cmd>OverseerToggle<CR>', { desc = 'Toggle tasks' })
		map('n', '<leader>ra', '<cmd>OverseerRun<CR>', { desc = 'Run task' })

		-- Trouble (diagnostics UI)
		map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics' })
		map('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix' })
		map('n', '<leader>xl', '<cmd>Trouble loclist toggle<CR>', { desc = 'Location list' })

		-- Debug keymaps
		map('n', '<leader>rd', function() require('dap').continue() end, { desc = 'Debug' })
		map('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Breakpoint' })
		map('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end, { desc = 'Conditional BP' })
		map('n', '<leader>dl', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log: ')) end, { desc = 'Log point' })
		map('n', '<leader>dc', function() require('dap').continue() end, { desc = 'Continue' })
		map('n', '<leader>dsi', function() require('dap').step_into() end, { desc = 'Step into' })
		map('n', '<leader>dso', function() require('dap').step_over() end, { desc = 'Step over' })
		map('n', '<leader>dsu', function() require('dap').step_out() end, { desc = 'Step out' })
		map('n', '<leader>dh', function() require('dap.ui.widgets').hover() end, { desc = 'Hover' })
		map('n', '<leader>dp', function() require('dap.ui.widgets').preview() end, { desc = 'Preview' })
		map('n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Terminate' })
		map('n', '<leader>dr', function() require('dap').restart() end, { desc = 'Restart' })
		
		-- Debug UI controls
		map('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Toggle UI' })
		map('n', '<leader>duo', function() require('dapui').open() end, { desc = 'Open UI' })
		map('n', '<leader>duc', function() require('dapui').close() end, { desc = 'Close UI' })
		map('n', '<leader>dur', function() require('dapui').open({ reset = true }) end, { desc = 'Reset UI' })
		map({ 'n', 'v' }, '<leader>de', function() require('dapui').eval() end, { desc = 'Eval' })

		-- which-key group labels (if which-key active)
		pcall(function()
			local wk = require 'which-key'
			wk.add({
				{ '<leader>w',  group = 'Window' },
				{ '<leader>ws', group = 'Split' },
				{ '<leader>f',  group = 'Find/Nav' },
				{ '<leader>g',  group = 'Git' },
				{ '<leader>r',  group = 'Run' },
				{ '<leader>x',  group = 'Trouble' },
				{ '<leader>d',  group = 'Debug' },
				{ '<leader>ds', group = 'Step' },
				{ '<leader>du', group = 'UI' },
			})
		end)
	end,
}
