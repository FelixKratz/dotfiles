local M = {}

M.movement = {
  n = {
    ["j"] = { "h", "Move Left" },
    ["k"] = { "j", "Move Down" },
    ["l"] = { "k", "Move Up" },
    ["ö"] = { "l", "Move Right" },
    ["h"] = { "%", "Move to matching bracket" },
    ["s"] = { ":w<CR>", "Save File" },
    ["q"] = { ":q<CR>", "Quit" },
    ["ß"] = { "$", "Move to EOL" },
    ["Y"] = { "y$", "Yank to EOL" },
    ["ä"] = { "za", "Toggle Fold" },
    ["Ä"] = { "zM", "Toggle all Folds" },
    ["<C-k>"] = { "<Esc>:m .+1<CR>", "Move Current Line Down" },
    ["<C-l>"] = { "<Esc>:m .-2<CR>", "Move Current Line Up" },
    ["<leader>t"] = { ":TodoTelescope<CR>", "Show Todo List" },
    ["<leader>c"] = { "<cmd> :lua require('Comment.api').toggle_current_linewise()<CR>", "Toggle Comment" },
  },

  v = {
    ["j"] = { "h", "Move Left" },
    ["k"] = { "j", "Move Down" },
    ["l"] = { "k", "Move Up" },
    ["ö"] = { "l", "Move Right" },
    ["h"] = { "%", "Move to matching bracket" },
    ["s"] = { ":w<CR>", "Save File" },
    ["ß"] = { "$", "Move to EOL" },
    ["Y"] = { "y$", "Yank to EOL" },
    ["ä"] = { "za", "Toggle Fold" },
    ["Ä"] = { "zM", "Toggle all Folds" },
    ["<C-k>"] = { ":m '>+1<CR>==gv", "Move Current Line Down" },
    ["<C-l>"] = { ":m '<-2<CR>==gv", "Move Current Line Up" },
    ["<leader>c"] = { "<esc><cmd> :lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", "Toggle Comment" },
  },
  i = {
    ["<C-k>"] = { "<Esc>:m .+1<CR>==gi", "Move Current Line Down" },
    ["<C-l>"] = { "<Esc>:m .-2<CR>==gi", "Move Current Line Up" },
  },
}

M.dap = {
  n = {
    ["<leader>q"] = { ':lua require"dap".close()<CR>', "Close DAP" },
    ["<leader>d"] = { ':lua require"dapui".toggle()<CR>', "Toggle DAP UI" },
    ["<leader>b"] = { ':lua require"dap".toggle_breakpoint()<CR>', "Toggle Breakpoint" },
    ["<leader>B"] = { ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', "Toggle Condition Breakpoint" },
    ["<leader>e"] = { ':lua require("dapui").eval()<CR>', "Evaluate Expression (DAP)" },
    ["<C-c>"] = { ':lua require"dap".continue()<CR>', "DAP Continue" },
    ["<C-s>"] = { ':lua require"dap".continue()<CR>', "DAP Step" },
    ["<C-Left>"] = { "<C-w>h", "Window Left" },
    ["<C-Down>"] = { "<C-w>j", "Window Down" },
    ["<C-Up>"] = { "<C-w>k", "Window Up" },
    ["<C-Right>"] = { "<C-w>l", "Window Right" },
  }
}

return M
