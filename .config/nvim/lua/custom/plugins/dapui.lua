local config = {
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "o", "<LeftMouse>" },
    open = "a",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
    elements = {
      -- Provide as ID strings or tables with "id" and "size" keys
      {
        id = "scopes",
        size = 0.5, -- Can be float or integer > 1
      },
      { id = "watches", size = 0.3 },
      { id = "breakpoints", size = 0.1 },
      { id = "stacks", size = 0.1 },
    },
      size = 60,
      position = 'left',
    },
    {
      elements = {
        'repl',
        'console',
      },
      size = 10,
      position = 'bottom',
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "rounded", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
}

require("dapui").setup(config)

vim.cmd("hi link DapUIVariable Normal")
vim.cmd("hi DapUIScope guifg=#6dc7e3")
vim.cmd("hi DapUIType guifg=#83c092")
vim.cmd("hi link DapUIValue Normal")
vim.cmd("hi DapUIModifiedValue guifg=#e69875 gui=bold")
vim.cmd("hi DapUIDecoration guifg=#6dc7e3")
vim.cmd("hi DapUIThread guifg=#9dd274")
vim.cmd("hi DapUIStoppedThread guifg=#6dc7e3")
vim.cmd("hi link DapUIFrameName Normal")
vim.cmd("hi DapUISource guifg=#ba9cf3")
vim.cmd("hi DapUILineNumber guifg=#6dc7e3")
vim.cmd("hi DapUIFloatBorder guifg=#6dc7e3")
vim.cmd("hi DapUIWatchesEmpty guifg=#ff6578")
vim.cmd("hi DapUIWatchesValue guifg=#9dd274")
vim.cmd("hi DapUIWatchesError guifg=#ff6578")
vim.cmd("hi DapUIBreakpointsPath guifg=#6dc7e3")
vim.cmd("hi DapUIBreakpointsInfo guifg=#9dd274")
vim.cmd("hi DapUIBreakpointsCurrentLine guifg=#9dd274 gui=bold")
vim.cmd("hi link DapUIBreakpointsLine DapUILineNumber")
vim.cmd("hi DapUIBreakpointsDisabledLine guifg=#424242")
