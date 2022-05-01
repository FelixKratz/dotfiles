return {
  ["williamboman/nvim-lsp-installer"] = {
     config = function()
        local lsp_installer = require "nvim-lsp-installer"

        lsp_installer.on_server_ready(function(server)
           local opts = {}

           server:setup(opts)
           vim.cmd [[ do User LspAttachBuffers ]]
        end)
     end,
  },

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
         require("core.utils").packer_lazy_load "neoscroll.nvim"
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

  ["luukvbaal/nnn.nvim"] = {
      config = function()
        require("nnn").setup()
      end
  },
}
