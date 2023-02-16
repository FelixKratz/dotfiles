local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup(
{
  "rafamadriz/friendly-snippets",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/cmp-nvim-lua",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-path",
  "junegunn/vim-easy-align",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "plugins.treesitter"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require "plugins.mason"
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require "plugins.mason_lspconfig"
    end,
  },
  {
    event = "BufEnter *.rs",
    "simrat39/rust-tools.nvim",
    config = function()
      require "rust-tools".setup()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require "plugins.cmp"
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = "onsails/lspkind.nvim",
    config = function()
      require "plugins.luasnip"
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require "lsp_signature".setup()
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require "plugins.blankline"
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require "gitsigns".setup()
    end
  },
  {
    lazy = true,
    "mfussenegger/nvim-dap",
    config = function()
      require "plugins.dap"
    end,
  },
  {
    event = "BufEnter *.py",
    "mfussenegger/nvim-dap-python",
    config = function()
      require "dap-python".setup("python")
    end,
  },
  {
    lazy = true,
    "rcarriga/nvim-dap-ui",
    config = function()
      require "plugins.dapui"
    end,
  },
  {
    lazy = true,
    "numToStr/Comment.nvim",
    config = function()
        require "Comment".setup()
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require "colorizer".setup()
    end
  },
  {
    "akinsho/bufferline.nvim",
    version = "v2.*",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = function()
      require "plugins.bufferline"
    end
  },
  {
    lazy = true,
    "luukvbaal/nnn.nvim",
    config = function()
      require("nnn").setup()
    end
  },
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require "todo-comments".setup()
    end
  },
  {
    lazy = true,
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
      vim.keymap.set("n", "f", "<Plug>(leap-forward)", {})
      vim.keymap.set("n", "F", "<Plug>(leap-backward)", {})
    end,
  },
  {
    lazy = true,
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("telescope").setup()
    end
  },
  {
    event = "BufEnter *.ju.py",
    "kiyoon/jupynium.nvim",
    build = "pip3 install --user .",
    config = function()
      require "plugins.jupynium"
    end
  },
  {
    priority = 1000,
    "catppuccin/nvim",
    name = "catppuccin",
    build = ":CatppuccinCompile",
    config = function()
      require "plugins.catppuccin"
    end
  },
  {
    lazy = true,
    "LeonHeidelbach/trailblazer.nvim",
    config = function()
        require("plugins.trailblazer")
    end
  },
})
