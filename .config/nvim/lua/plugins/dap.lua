local dap = require('dap')

dap.adapters.lldb = {
  type = 'executable',
  command = '/opt/homebrew/opt/llvm/bin/lldb-vscode', -- adjust as needed
  name = "lldb"
}

dap.configurations.c = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      local cwd = vim.fn.getcwd()
      return cwd .. '/bin/' .. cwd.match(cwd, "/(%w+)$")
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    runInTerminal = false,
    postRunCommands = {'process handle -p true -s false -n false SIGWINCH'}
  },
}

dap.configurations.cpp = dap.configurations.c
dap.configurations.objc = dap.configurations.c
dap.configurations.rust = dap.configurations.cpp
