return {
  {
     "williamboman/nvim-lsp-installer",
     config = function()
        local lsp_installer = require "nvim-lsp-installer"

        lsp_installer.on_server_ready(function(server)
           local opts = {}

           server:setup(opts)
           vim.cmd [[ do User LspAttachBuffers ]]
        end)
     end,
  },
  {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end,
  },
  {
    "junegunn/vim-easy-align",
  },
}
