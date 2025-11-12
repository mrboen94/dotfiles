return {
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      automatic_installation = true,
      ensure_installed = { 'codelldb' },
    },
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    opts = {},
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = {},
  },
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      
      if vim.fn.has('win32') == 1 then
        dap.adapters.rad = { type = 'executable', command = 'remedybg.exe' }
        dap.configurations.c = {{ name = 'RAD Debugger', type = 'rad', request = 'launch', program = function() return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file') end }}
        dap.configurations.cpp = dap.configurations.c
      else
        dap.adapters.codelldb = { type = 'server', port = '${port}', executable = { command = vim.fn.stdpath('data') .. '/mason/bin/codelldb', args = { '--port', '${port}' } } }
        dap.configurations.c = {{ name = 'lldb', type = 'codelldb', request = 'launch', program = function() return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file') end, cwd = '${workspaceFolder}' }}
        dap.configurations.cpp = dap.configurations.c
        dap.configurations.rust = dap.configurations.c
      end
      
      -- Note: Odin configurations are set up by the nvim-dap-odin plugin

      require('dapui').setup()
      dap.listeners.after.event_initialized['dapui_config'] = require('dapui').open
      dap.listeners.before.event_terminated['dapui_config'] = require('dapui').close
      dap.listeners.before.event_exited['dapui_config'] = require('dapui').close
    end,
  },
}
