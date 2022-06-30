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

  ['mfussenegger/nvim-dap-python'] = {
    after = "nvim-dap",
    config = function()
      require('dap-python').setup('python')
    end,
  },

  ["rcarriga/nvim-dap-ui"] = {
    after = "nvim-dap",
    config = function()
      require "custom.plugins.dapui"
    end,
  },

  ["feline-nvim/feline.nvim"] = {
    after = "base46",
    config = function()
      require "custom.plugins.feline"
    end,
  }
}
