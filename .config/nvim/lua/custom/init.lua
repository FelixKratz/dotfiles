local map = nvchad.map

map("n", "j", "h")
map("n", "k", "j")
map("n", "l", "k")
map("n", "ö", "l")
map("n", "h", "%")
map("n", "ß", "$")
map("n", "Y", "y$")
map("n", "ä", "za")
map("n", "Ä", "zM")
map("n", "<C-k>", "<Esc>:m .+1<CR>")
map("n", "<C-l>", "<Esc>:m .-2<CR>")
map("n", "<leader>t", ":TodoTelescope<CR>")
map("n", "s", ":w<CR>")
map("n", "<Leader>q", ':lua require"dap".close()<CR>')
map("n", "<Leader>d", ':lua require"dapui".toggle()<CR>')
map("n", "<Leader>b", ':lua require"dap".toggle_breakpoint()<CR>')
map("n", "<Leader>B", ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>')
map("n", "<C-c>", ':lua require"dap".continue()<CR>')
map("n", "<C-s>", ':lua require"dap".step_into()<CR>')
map("n", "<C-Left>", "<C-w>h")
map("n", "<C-Down>", "<C-w>j")
map("n", "<C-Up>", "<C-w>k")
map("n", "<C-Right>", "<C-w>l")
map("n", "<Leader>e", ':lua require("dapui").eval()<CR>')
map("n", "q", ':q<CR>')
map("n", "<leader>c", "<cmd> :lua require('Comment.api').toggle_current_linewise()<CR>")

map("v", "<leader>c", "<esc><cmd> :lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>")
map("v", "j", "h")
map("v", "k", "j")
map("v", "l", "k")
map("v", "ö", "l")
map("v", "h", "%")
map("v", "ß", "$")
map("v", "Y", "y$")
map("v", "<leader>a", ":LiveEasyAlign<CR>")
map("v", "<C-k>", ":m '>+1<CR>==gv")
map("v", "<C-l>", ":m '<-2<CR>==gv")

map("i", "<C-k>", "<Esc>:m .+1<CR>==gi")
map("i", "<C-l>", "<Esc>:m .-2<CR>==gi")

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

vim.cmd("hi IndentBlanklineContextChar guifg=#e1e3e4 gui=nocombine")
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
