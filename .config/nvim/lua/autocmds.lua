local autocmd = vim.api.nvim_create_autocmd

-- Use relative & absolute line numbers in 'n' & 'i' modes respectively
autocmd("InsertEnter", {
  callback = function()
    vim.opt.relativenumber = true
  end,
})

autocmd("InsertLeave", {
  callback = function()
    vim.opt.relativenumber = false
  end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 100 }
  end,
})

-- Enable spellchecking in markdown, text and gitcommit files
autocmd("FileType", {
  pattern = { "gitcommit", "markdown", "text", "tex" },
  callback = function()
    vim.opt_local.spell = true
  end,
})
