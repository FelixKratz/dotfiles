local lsp = require("feline.providers.lsp")
local lsp_severity = vim.diagnostic.severity
local b = vim.b

local assets = {
  left_semicircle = "",
  right_semicircle = "",
  right_semicircle_cut = "",
  left_semicircle_cut = "",
  vertical_bar_chubby = "█",
  vertical_bar_medium = "┃",
  vertical_bar_thin = "│",
  left_arrow_thin = "",
  right_arrow_thin = "",
  left_arrow_filled = "",
  right_arrow_filled = "",
  slant_left = "",
  slant_left_thin = "",
  slant_right = "",
  slant_right_thin = "",
  slant_left_2 = "",
  slant_left_2_thin = "",
  slant_right_2 = "",
  slant_right_2_thin = "",
  chubby_dot = "●",
  slim_dot = "•",
}

local clrs = require("catppuccin.palettes").get_palette()

-- settings
local sett = {
  bkg = clrs.surface0,
  diffs = clrs.overlay0,
  extras = clrs.overlay1,
  position = clrs.rosewater,
}

local mode_colors = {
  ["n"] = { "NORMAL", clrs.lavender },
  ["no"] = { "N-PENDING", clrs.lavender },
  ["i"] = { "INSERT", clrs.rosewater },
  ["ic"] = { "INSERT", clrs.rosewater },
  ["t"] = { "TERMINAL", clrs.green },
  ["v"] = { "VISUAL", clrs.flamingo },
  ["V"] = { "V-LINE", clrs.flamingo },
  [""] = { "V-BLOCK", clrs.flamingo },
  ["R"] = { "REPLACE", clrs.maroon },
  ["Rv"] = { "V-REPLACE", clrs.maroon },
  ["s"] = { "SELECT", clrs.maroon },
  ["S"] = { "S-LINE", clrs.maroon },
  [""] = { "S-BLOCK", clrs.maroon },
  ["c"] = { "COMMAND", clrs.red },
  ["cv"] = { "COMMAND", clrs.red },
  ["ce"] = { "COMMAND", clrs.red },
  ["r"] = { "PROMPT", clrs.teal },
  ["rm"] = { "MORE", clrs.teal },
  ["r?"] = { "CONFIRM", clrs.mauve },
  ["!"] = { "SHELL", clrs.green },
}

local M = {}

function M.get()
  local shortline = false

  local function is_enabled(is_shortline, winid, min_width)
    if is_shortline then
      return true
    end

    winid = winid or 0
    return vim.api.nvim_win_get_width(winid) > min_width
  end

  -- Initialize the components table
  local components = {
    active = {},
    inactive = {},
  }

  table.insert(components.active, {}) -- (1) left
  table.insert(components.active, {}) -- (2) center
  table.insert(components.active, {}) -- (3) right

  -- global components
  local invi_sep = {
    str = " ",
    hl = {
      fg = sett.bkg,
      bg = sett.bkg,
    },
  }

  -- helpers
  local function any_git_changes()
    local gst = b.gitsigns_status_dict -- git stats
    if gst then
      if gst["added"] and gst["added"] > 0
        or gst["removed"] and gst["removed"] > 0
        or gst["changed"] and gst["changed"] > 0 then
          return true
      end
    end
    return false
  end

  -- #################### STATUSLINE ->

  -- ######## Left

  -- Current vi mode ------>
  local vi_mode_hl = function()
    return {
      fg = sett.bkg,
      bg = mode_colors[vim.fn.mode()][2],
      style = "bold",
    }
  end

  components.active[1][1] = {
    provider = assets.vertical_bar_chubby,
    hl = function()
      return {
        fg = mode_colors[vim.fn.mode()][2],
        bg = sett.bkg,
      }
    end,
  }

  components.active[1][2] = {
    provider = "",
    hl = function()
      return {
        fg = sett.bkg,
        bg = mode_colors[vim.fn.mode()][2],
      }
    end,
  }

  components.active[1][3] = {
    provider = function()
      return " " .. mode_colors[vim.fn.mode()][1]
    end,
    hl = vi_mode_hl,
  }

  -- there is a dilema: we need to hide Diffs if there is no git info. We can do that, but this will
  -- leave the right_semicircle colored with purple, and since we can't change the color conditonally
  -- then the solution is to create two right_semicircles: one with a mauve sett.bkg and the other one normal
  -- sett.bkg; both have the same fg (vi mode). The mauve one appears if there is git info, else the one with
  -- the normal sett.bkg appears. Fixed :)

  -- enable if git diffs are not available
  components.active[1][4] = {
    provider = assets.right_semicircle,
    hl = function()
      return {
        fg = mode_colors[vim.fn.mode()][2],
        bg = sett.bkg,
      }
    end,
    enabled = function()
      return not any_git_changes()
    end,
  }

  -- enable if git diffs are available
  components.active[1][5] = {
    provider = assets.right_semicircle,
    hl = function()
      return {
        fg = mode_colors[vim.fn.mode()][2],
        bg = sett.diffs,
      }
    end,
    enabled = function()
      return any_git_changes()
    end,
  }
  -- Current vi mode ------>

  -- Diffs ------>
  components.active[1][6] = {
    provider = "git_diff_added",
    hl = {
      fg = sett.bkg,
      bg = sett.diffs,
    },
    icon = "  ",
  }

  components.active[1][7] = {
    provider = "git_diff_changed",
    hl = {
      fg = sett.bkg,
      bg = sett.diffs,
    },
    icon = "  ",
  }

  components.active[1][8] = {
    provider = "git_diff_removed",
    hl = {
      fg = sett.bkg,
      bg = sett.diffs,
    },
    icon = "  ",
  }

  components.active[1][9] = {
    provider = assets.right_semicircle,
    hl = {
      fg = sett.diffs,
      bg = sett.bkg,
    },
    enabled = function()
      return any_git_changes()
    end,
  }

  components.active[1][10] = {
    provider = "git_branch",
    enabled = is_enabled(shortline, winid, 70),
    hl = {
      fg = sett.extras,
      bg = sett.bkg,
    },
    icon = "  ",
    left_sep = invi_sep,
    right_sep = invi_sep,
  }


  -- Diffs ------>

  -- Extras ------>

  -- Extras ------>

  -- ######## Left

  -- ######## Center

  -- Diagnostics ------>
  -- workspace loader
  components.active[2][1] = {
    provider = function()
      local Lsp = vim.lsp.util.get_progress_messages()[1]

      if Lsp then
        local msg = Lsp.message or ""
        local percentage = Lsp.percentage or 0
        local title = Lsp.title or ""
        local spinners = {
          "",
          "",
          "",
        }
        local success_icon = {
          "",
          "",
          "",
        }
        local ms = vim.loop.hrtime() / 1000000
        local frame = math.floor(ms / 120) % #spinners

        if percentage >= 70 then
          return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1], title, msg, percentage)
        end

        return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
      end

      return ""
    end,
    enabled = is_enabled(shortline, winid, 80),
    hl = {
      fg = clrs.rosewater,
      bg = sett.bkg,
    },
  }

  -- genral diagnostics (errors, warnings. info and hints)
  components.active[2][2] = {
    provider = "diagnostic_errors",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.ERROR)
    end,

    hl = {
      fg = clrs.red,
      bg = sett.bkg,
    },
    icon = "  ",
  }

  components.active[2][3] = {
    provider = "diagnostic_warnings",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.WARN)
    end,
    hl = {
      fg = clrs.yellow,
      bg = sett.bkg,
    },
    icon = "  ",
  }

  components.active[2][4] = {
    provider = "diagnostic_info",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.INFO)
    end,
    hl = {
      fg = clrs.sky,
      bg = sett.bkg,
    },
    icon = "  ",
  }

  components.active[2][5] = {
    provider = "diagnostic_hints",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.HINT)
    end,
    hl = {
      fg = clrs.rosewater,
      bg = sett.bkg,
    },
    icon = "  ",
  }

  components.active[3][1] = {
    provider = function()
      if next(vim.lsp.buf_get_clients()) ~= nil then
        return " LSP "
      else
        return ""
      end
    end,
    hl = {
      fg = sett.extras,
      bg = sett.bkg,
    },
    right_sep = invi_sep,
  }

  components.active[3][2] = {
    provider = function()
      local current_line = vim.fn.line "."
      local current_col = vim.fn.col "."
      local total_line = vim.fn.line "$"

      if current_col < 10 then
        current_col = " " .. current_col
      end

      if current_line == 1 then
        return " " .. current_line .. ":" .. current_col .. "/" .. "Top "
      elseif current_line == vim.fn.line "$" then
        return " " .. current_line .. ":" .. current_col .. "/" .. "Bot "
      end
      local result, _ = math.modf((current_line / total_line) * 100)

      if result < 10 then
        result = " " .. result
      end

      return " " .. current_line .. ":" .. current_col .. "/" .. result .. "%% "
    end,

    hl = {
      fg = sett.bkg,
      bg = sett.position,
    },
    left_sep = {
      str = assets.left_semicircle,
      hl = {
        fg = sett.position,
        bg = sett.bkg,
      },
    },
  }
  return components
end

require("feline").setup( { components = M.get() } )

