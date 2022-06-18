require("core.utils").load_mappings()

vim.cmd("set foldcolumn=1")
vim.cmd("set foldenable")
vim.cmd("set foldlevel=99")
vim.cmd("set foldmethod=indent")
vim.cmd("set foldnestmax=99")

vim.cmd("set colorcolumn=80")
vim.cmd("set noshowmode")

vim.cmd("hi link DapUIVariable Normal")
vim.cmd("hi DapUIScope guifg=#6dc7e3")
vim.cmd("hi DapUIType guifg=#83c092")
vim.cmd("hi link DapUIValue Normal")
vim.cmd("hi DapUIModifiedValue guifg=#e69875 gui=bold")
vim.cmd("hi DapUIDecoration guifg=#6dc7e3")
vim.cmd("hi DapUIThread guifg=#9dd274")
vim.cmd("hi DapUIStoppedThread guifg=#6dc7e3")
vim.cmd("hi link DapUIFrameName Normal")
vim.cmd("hi DapUISource guifg=#ba9cf3")
vim.cmd("hi DapUILineNumber guifg=#6dc7e3")
vim.cmd("hi DapUIFloatBorder guifg=#6dc7e3")
vim.cmd("hi DapUIWatchesEmpty guifg=#ff6578")
vim.cmd("hi DapUIWatchesValue guifg=#9dd274")
vim.cmd("hi DapUIWatchesError guifg=#ff6578")
vim.cmd("hi DapUIBreakpointsPath guifg=#6dc7e3")
vim.cmd("hi DapUIBreakpointsInfo guifg=#9dd274")
vim.cmd("hi DapUIBreakpointsCurrentLine guifg=#9dd274 gui=bold")
vim.cmd("hi link DapUIBreakpointsLine DapUILineNumber")
vim.cmd("hi DapUIBreakpointsDisabledLine guifg=#424242")

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
    if require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
      and not require("luasnip").session.jump_active then
      require("luasnip").unlink_current()
    end
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
