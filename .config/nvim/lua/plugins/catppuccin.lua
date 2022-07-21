vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

local cp = require("catppuccin.palettes").get_palette() -- fetch colors from palette

local options = {
  transparent_background = true,
  compile = {
    enabled = true,
    path = vim.fn.stdpath "cache" .. "/catppuccin"
  },
  integrations = {
    dap = {
      enabled = true,
      enable_ui = true,
    }
  },
  custom_highlights = {
    Comment = { fg = cp.surface2, style = { "italic" } }, -- just comments
    Constant = { fg = cp.peach }, -- (preferred) any constant
    String = { fg = cp.yellow, style = { "italic", "bold" } }, -- a string constant: "this is a string"
    Character = { fg = cp.teal }, --  a character constant: 'c', '\n'
    Number = { fg = cp.maroon }, --   a number constant: 234, 0xff
    Float = { fg = cp.maroon }, --    a floating point constant: 2.3e10
    Boolean = { fg = cp.maroon }, --  a boolean constant: TRUE, false
    Identifier = { fg = cp.text }, -- (preferred) any variable name
    Function = { fg = cp.green }, -- function name (also: methods for classes)
    Statement = { fg = cp.mauve }, -- (preferred) any statement
    Conditional = { fg = cp.red }, --  if, then, else, endif, switch, etcp.
    Repeat = { fg = cp.red }, --   for, do, while, etcp.
    Label = { fg = cp.peach }, --    case, default, etcp.
    Operator = { fg = cp.text }, -- "sizeof", "+", "*", etcp.
    Keyword = { fg = cp.pink }, --  any other keyword
    PreProc = { fg = cp.peach }, -- (preferred) generic Preprocessor
    Include = { fg = cp.green }, --  preprocessor #include
    StorageClass = { fg = cp.yellow }, -- static, register, volatile, etcp.
    Structure = { fg = cp.yellow }, --  struct, union, enum, etcp.
    Typedef = { fg = cp.yellow }, --  A typedef
    Special = { fg = cp.peach }, -- (preferred) any special symbol
    Type = { fg = cp.teal }, -- (preferred) int, long, char, etcp.
    TSInclude = { fg = cp.peach, style = { "italic" } },
    TSField = { fg = cp.blue }, -- For fields.
    TSProperty = { fg = cp.blue }, -- Same as TSField.
    TSConstant = { fg = cp.maroon }, -- For constants
    TSParameter = { fg = cp.text, style = { "italic" } }, -- For parameters of a function.
    TSOperator = { fg = cp.text },
    TSKeywordFunction = { fg = cp.peach }, -- For keywords used to define a fuction.
    TSKeyword = { fg = cp.peach }, -- For keywords that don't fall in previous categories.
    TSKeywordReturn = { fg = cp.peach },
    TSType = { fg = cp.teal }, -- For types.
    TSTypeBuiltin = { fg = cp.teal, style = { "italic" } }, -- For builtin types.
    TSVariableBuiltin = { fg = cp.red }, -- Variable names that are defined by the languages, like this or self.
    TSFunction = { fg = cp.green }, -- For function (calls and definitions).
    TSMethod = { fg = cp.green }, -- For method calls and definitions.
    TSString = { fg = cp.yellow, style = { "italic" } }, -- For strings.
    BufferLineSeparator = { fg = cp.peach, bg = "NONE" },
    BufferLineBufferVisible = { fg = cp.surface1, bg = "NONE" },
    BufferLineBufferSelected = { fg = cp.text, bg = "NONE", style = { "bold", "italic" } }, -- current
    BufferLineIndicatorSelected = { fg = cp.peach, bg = "NONE" },
  }
}

require("catppuccin").setup(options)

vim.cmd [[colorscheme catppuccin]]
