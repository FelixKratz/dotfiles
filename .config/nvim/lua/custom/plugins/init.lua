return {
  ["folke/todo-comments.nvim"] = {
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end,
  },

  ["junegunn/vim-easy-align"] = {},

  ["karb94/neoscroll.nvim"] = {
    opt = true,
    config = function()
      require("neoscroll").setup()
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

  ['mfussenegger/nvim-dap-python'] = {
    after = "nvim-dap",
    config = function()
      require('dap-python').setup('python')
    end,
  },

  ["feline-nvim/feline.nvim"] = {
    config = function()
      require "custom.plugins.feline"
    end,
  }
}
