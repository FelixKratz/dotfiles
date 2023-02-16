local colors = require("catppuccin.palettes").get_palette() -- fetch colors from palette
require("trailblazer").setup(
{
  lang = "en",
  trail_options = {
    available_trail_mark_modes = { -- available modes to cycle through
      "global_chron_buf_switch_group_chron",
      "buffer_local_line_sorted"
    },
    current_trail_mark_mode               = "global_chron_buf_switch_group_chron",
    verbose_trail_mark_select             = true,
    newest_mark_symbol                    = "",
    cursor_mark_symbol                    = "",
    next_mark_symbol                      = "ﭠ",
    previous_mark_symbol                  = "ﭢ",
    number_line_color_enabled             = true,
    symbol_line_enabled                   = true,
    multiple_mark_symbol_counters_enabled = false,
  },
  force_mappings = nil,
  hl_groups = {
    TrailBlazerTrailMarkNext = {
      guifg = colors.overlay0,
      guibg = "none",
    },
    TrailBlazerTrailMarkPrevious = {
      guifg = colors.overlay0,
      guibg = "none",
    },
    TrailBlazerTrailMarkCursor = {
      guifg = colors.crust,
      guibg = colors.green,
    },
    TrailBlazerTrailMarkNewest = {
      guifg = colors.crust,
      guibg = colors.sky,
    },
    TrailBlazerTrailMarkGlobalChronBufSwitchGroupChron = {
      guifg = colors.crust,
      guibg = colors.peach,
    },
    TrailBlazerTrailMarkBufferLocalLineSorted = {
      guifg = colors.crust,
      guibg = colors.mauve,
    },
  },
})
