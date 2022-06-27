local M = {}

local userPlugins = require "custom.plugins"

M.options = {
  user = function()
    vim.opt.clipboard = "unnamed"
    vim.opt.cul = false
    vim.opt.mouse = "nv"
    vim.cmd("set foldcolumn=1")
    vim.cmd("set foldenable")
    vim.cmd("set foldlevel=99")
    vim.cmd("set foldmethod=indent")
    vim.cmd("set foldnestmax=99")
    vim.cmd("set colorcolumn=80")
    vim.cmd("set noshowmode")
  end,
}

M.ui = {
  -- This is grey but not italic
  hl_override = {
    Comment = { italic = true },
    IndentBlanklineContextChar = { fg="#e1e3e4" },
  },
  theme = "penokai",
  transparency = true,
}

M.plugins = {
  override = {
    ["nvim-treesitter/nvim-treesitter"] = {
      ensure_installed = {
        "c",
        "lua",
        "cpp",
        "python",
        "bash",
        "latex",
      },
    },

    ["lukas-reineke/indent-blankline.nvim"] = {
      show_trailing_blankline_indent = true,
      show_first_indent_level = true,
      show_current_context = true,
      show_current_context_start = false,
      char = "│",
    },

    ["akinsho/bufferline.nvim"] = {
      options = {
        always_show_bufferline = true,
        custom_areas = false,
        max_name_length = 20,
      },
    },
  },
  remove = {
    "folke/which-key.nvim",
    "akinsho/bufferline.nvim",
    "feline-nvim/feline.nvim",
    "kyazdani42/nvim-tree.lua",
    "goolord/alpha-nvim",
    "NvChad/nvterm",
  },

  options = {
    packer = {
      init_file = "plugins.packerInit",
      snapshot = nil,
    },
    statusline = {
      separator_style = "default", -- default/round/slant/block/arrow
    },
    lspconfig = {
      setup_lspconf = "custom.plugins.lspconfig"
    }
  },

  -- add, modify, remove plugins
  user = userPlugins,
}

M.mappings = require "custom.mappings"

return M
