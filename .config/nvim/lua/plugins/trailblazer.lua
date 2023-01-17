local colors = require("catppuccin.palettes").get_palette() -- fetch colors from palette
require("trailblazer").setup(
{
  lang = "en",
  mappings = {
    nv = { -- Mode union: normal & visual mode. Can be extended by adding i, x, ...
      motions = {
        new_trail_mark = '<C-m>',
        track_back = '<C-b>',
        peek_move_backward = '<C-l>',
        peek_move_forward = '<C-k>',
      },
        actions = {
        delete_all_trail_marks = '<C-j>',
        paste_at_last_trail_mark = '<A-p>',
        paste_at_all_trail_marks = '<A-P>',
      },
    },
  },
  hl_groups = {
    TrailBlazerTrailMark = {
      -- You can add any valid highlight group attribute to this table
      guifg = colors.crust,
      guibg = colors.red,
      gui = "bold",
    },
  },
})
