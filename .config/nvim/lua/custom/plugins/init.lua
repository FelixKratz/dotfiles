return {
  ["folke/todo-comments.nvim"] = {
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end,
  },

  ["junegunn/vim-easy-align"] = {},
  ["tpope/vim-surround"] = {},
  ["tpope/vim-fugitive"] = {},

  ["karb94/neoscroll.nvim"] = {
    opt = true,
    config = function()
      require("neoscroll").setup()
    end,

    -- lazy loading
    setup = function()
      nvchad.packer_lazy_load "neoscroll.nvim"
    end,
  },

  ["mfussenegger/nvim-dap"] = {
    config = function()
      require "custom.plugins.dap"
    end,
  },

  ["rcarriga/nvim-dap-ui"] = {
    after = "nvim-dap",
    config = function()
      require "custom.plugins.dapui"
    end,
  },

  ["feline-nvim/feline.nvim"] = {
    config = function()
      require "custom.plugins.feline"
    end
  }
}
