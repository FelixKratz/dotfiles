local M = {}

function M.init()
  local colors = require("catppuccin.palettes").get_palette()
  require("trailblazer").setup(
  {
    custom_session_storage_dir = "~/tb_sessions/",
    trail_options = {
      available_trail_mark_modes = {
        "global_chron_buf_switch_group_chron",
        "buffer_local_line_sorted"
      },
      current_trail_mark_mode = "global_chron_buf_switch_group_chron",
      verbose_trail_mark_select = false,
      mark_symbol = "•",
      newest_mark_symbol = "",
      cursor_mark_symbol = "",
      next_mark_symbol = "ﭠ",
      previous_mark_symbol = "ﭢ",
      multiple_mark_symbol_counters_enabled = false,
      trail_mark_symbol_line_indicators_enabled = true,
      trail_mark_list_rows = 5,
      move_to_nearest_before_peek = true,
      move_to_nearest_before_peek_motion_directive_up = "up",
      move_to_nearest_before_peek_motion_directive_down = "down",
    },
    event_list = {
      -- "TrailBlazerTrailMarkStackSaved",
      -- "TrailBlazerTrailMarkStackDeleted",
      "TrailBlazerCurrentTrailMarkStackChanged",
      -- "TrailBlazerTrailMarkStackSortModeChanged"
    },
    mappings = nil,
    quickfix_mappings = {
      v = {
        actions = {
          qf_action_move_selected_trail_marks_down = "<C-k>",
          qf_action_move_selected_trail_marks_up = "<C-l>",
        }
      }
    },
    hl_groups = {
      TrailBlazerTrailMark = {
        guifg = colors.overlay0,
        guibg = "none",
        gui = "bold",
      },
      TrailBlazerTrailMarkNext = {
        guifg = colors.overlay1,
        guibg = "none",
      },
      TrailBlazerTrailMarkPrevious = {
        guifg = colors.overlay1,
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
      TrailBlazerTrailMarkCustomOrd = {
        guifg = colors.crust,
        guibg = colors.yellow,
        gui = "bold",
      },
    },
  })

  function M.save_all_sessions()
    require("trailblazer.trails.stacks").add_stack()
    local buffers = require("trailblazer.trails.stacks").create_buf_file_lookup_table(true)
    if vim.tbl_isempty(buffers) then
      local open_bufs = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf)
      end, vim.api.nvim_list_bufs())

      for _, buffer in ipairs(open_bufs) do
        local buf_name = vim.api.nvim_buf_get_name(buffer)
        local file = vim.fn.expand(require("trailblazer").options.custom_session_storage_dir .. vim.fn.sha256(vim.fn.expand(buf_name)) .. ".tbsv")
        if vim.fn.filereadable(file) == 1 then
          vim.fn.delete(file)
        end
      end
    else
      for _, buf in ipairs(buffers) do
        M.save_session(buf)
      end
    end
  end

  function M.save_session(buf)
    buf = buf or vim.api.nvim_buf_get_name(0)
    local file = require("trailblazer").options.custom_session_storage_dir .. vim.fn.sha256(vim.fn.expand(buf)) .. ".tbsv"
    require("trailblazer").save_trailblazer_state_to_file(file, nil, false)
    print("Saved Session")
  end

  local autocmd = vim.api.nvim_create_autocmd
  autocmd("User", {
    pattern = "TrailBlazerCurrentTrailMarkStackChanged",
    callback = function(event)
      local line = "Stacks: "
      for _ ,stack in ipairs(event.data.available_stacks) do
        if stack == event.data.current_stack then
          line = line .. "[ " .. stack .. " ]  "
        else
          line = line .. "  " .. stack .. "    "
        end
      end

      vim.opt.statusline = line
    end,
  })

  autocmd("VimLeavePre", {
    pattern = "*",
    callback = function(_)
      M.save_all_sessions()
    end,
  })
end

function M.save_all_sessions()
  print("TrailBlazer not loaded...")
end

function M.new_mark()
  local tb = require("trailblazer")
  tb.new_trail_mark()
  tb.open_trail_mark_list()
  vim.cmd('wincmd p')
end

function M.load_session()
  local tb = require("trailblazer")
  local file = tb.options.custom_session_storage_dir .. vim.fn.sha256(vim.fn.expand(vim.api.nvim_buf_get_name(0))) .. ".tbsv"
  tb.load_trailblazer_state_from_file(file, false)
  tb.open_trail_mark_list()
  vim.cmd('wincmd p')
end

function M.add_stack()
  vim.ui.input({ prompt = "Stack Name: " }, function(input)
    require("trailblazer").switch_trail_mark_stack(input, false)
  end)
end

function M.delete_all_marks()
  local tb = require("trailblazer")
  tb.close_trail_mark_list()
  tb.delete_all_trail_marks()
  vim.opt.statusline=" "
end

return M
