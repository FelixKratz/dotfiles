local options = {
  ensure_installed = {
    "lua",
    "c",
    "cpp",
    "python"
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  },
}

require("nvim-treesitter.configs").setup(options)
