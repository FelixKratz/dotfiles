local colors = require("catppuccin.palettes").get_palette() -- fetch colors from palette
require("trailblazer").setup(
{
  lang = "en",
  trail_options = {
    -- Available modes to cycle through. Remove any you don't need.
    available_trail_mark_modes = { "global_line_sorted", "buffer_local_line_sorted" },
    -- The current / initially selected trail mark selection mode. Choose from one of the
    -- available modes: global, global_line_sorted, buffer_local, buffer_local_line_sorted
    current_trail_mark_mode = "buffer_local_line_sorted",
    verbose_trail_mark_select = true, -- print current mode notification on mode change
  },
  mappings = {
    nv = { -- Mode union: normal & visual mode. Can be extended by adding i, x, ...
      motions = {
        new_trail_mark     = '<C-m>',
        track_back         = '<C-b>',
        peek_move_backward = '<C-k>',
        peek_move_forward  = '<C-l>',
      },
      actions = {
        delete_all_trail_marks     = '<C-j>',
        paste_at_last_trail_mark   = '<A-p>',
        paste_at_all_trail_marks   = '<A-P>',
        set_trail_mark_select_mode = '<C-t>',
      },
    },
  },
  hl_groups = {
    TrailBlazerTrailMarkCursor = {
      -- You can add any valid highlight group attribute to this table
      guifg = colors.crust,
      guibg = colors.orange,
      gui   = "bold",
    },
    TrailBlazerTrailMarkNewest = {
      guifg = colors.crust,
      guibg = colors.sky,
      gui   = "bold",
    },
    TrailBlazerTrailMarkGlobal = {
      guifg = colors.crust,
      guibg = colors.mauve,
      gui   = "bold",
    },
    TrailBlazerTrailMarkGlobalLineSorted = {
      guifg = colors.crust,
      guibg = colors.red,
      gui   = "bold",
    },
    TrailBlazerTrailMarkBufferLocal = {
      guifg = colors.crust,
      guibg = colors.green,
      gui   = "bold",
    },
    TrailBlazerTrailMarkBufferLocalLineSorted = {
      guifg = colors.crust,
      guibg = colors.lavender,
      gui   = "bold",
    },
  },
})
