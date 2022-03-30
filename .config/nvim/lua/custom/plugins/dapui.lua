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
  sidebar = {
    -- You can change the order of elements in the sidebar
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
    position = "left", -- Can be "left", "right", "top", "bottom"
  },
  tray = {
    elements = { "repl" },
    size = 10,
    position = "bottom", -- Can be "left", "right", "top", "bottom"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "rounded", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
}

require("dapui").setup(config)
