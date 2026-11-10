local dap = require('dap')

dap.adapters.lldb = {
  type = 'executable',
  -- Homebrew llvm on Apple Silicon or Intel; lldb-vscode became lldb-dap in LLVM 18
  command = (function()
    for _, p in ipairs({
      '/opt/homebrew/opt/llvm/bin/lldb-dap', '/usr/local/opt/llvm/bin/lldb-dap',
      '/opt/homebrew/opt/llvm/bin/lldb-vscode', '/usr/local/opt/llvm/bin/lldb-vscode',
    }) do
      if vim.fn.executable(p) == 1 then return p end
    end
    return 'lldb-dap'
  end)(),
  name = "lldb"
}

dap.configurations.c = {
  {
    name = "Launch",
    type = "lldb",
    request = "launch",
    program = function()
      local cwd = vim.fn.getcwd()
      return cwd .. '/bin/debug'
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
