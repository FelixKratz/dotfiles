local options = {
  indentLine_enabled = 1,
  filetype_exclude = {
    "help",
    "terminal",
    "packer",
    "lspinfo",
    "TelescopePrompt",
    "TelescopeResults",
    "lsp-installer",
    "",
  },
  buftype_exclude = { "terminal" },
  show_trailing_blankline_indent = true,
  show_first_indent_level = true,
  show_current_context = true,
  show_current_context_start = false,
  show_end_of_line = true,
}

require("indent_blankline").setup(options)
