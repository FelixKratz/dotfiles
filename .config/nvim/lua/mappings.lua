vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = { silent = true, noremap = true }

-- General movements
vim.keymap.set("", "j", "h", opts)
vim.keymap.set("", "k", "j", opts)
vim.keymap.set("", "l", "k", opts)
vim.keymap.set("", "ö", "l", opts)
vim.keymap.set("", "ß", "$", opts)
vim.keymap.set("", "Y", "y$", opts)
vim.keymap.set("", "ä", "za", opts)
vim.keymap.set("", "Ä", "zR", opts)
vim.keymap.set("", "K", "<C-e>", opts)
vim.keymap.set("", "L", "<C-y>", opts)

-- Delete/change up to next )
vim.keymap.set("n", "d)", "d])")
vim.keymap.set("n", "c)", "c])")

-- Save and quit
vim.keymap.set("n", "s", ":w<CR>", opts)
vim.keymap.set("n", "Q", ":qa<CR>", opts)
vim.keymap.set("n", "<leader>x", ':bd<CR>', opts)

-- Window Movement
vim.keymap.set("n", "<C-Left>", "<C-w>h", opts)
vim.keymap.set("n", "<C-Down>", "<C-w>j", opts)
vim.keymap.set("n", "<C-Up>", "<C-w>k", opts)
vim.keymap.set("n", "<C-Right>", "<C-w>l", opts)

-- Telescope
vim.keymap.set("n", "<leader>fw", ':lua require("telescope")<CR> <cmd>Telescope live_grep<cr>', opts)

-- Bufferline
vim.keymap.set("n", "<TAB>", ":BufferLineCycleNext<CR>", opts)
vim.keymap.set("n", "<S-TAB>", ":BufferLineCyclePrev<CR>", opts)

-- nnn
vim.keymap.set("n", "<leader>n", ':lua require("nnn")<CR> :NnnPicker<CR>', opts)
vim.keymap.set("n", "<leader>N", ':lua require("nnn")<CR> :NnnExplorer<CR>', opts)

-- Leap
vim.keymap.set("n", "f", ':lua require("leap")<CR> <Plug>(leap-forward)', opts)
vim.keymap.set("n", "F", ':lua require("leap")<CR> <Plug>(leap-backward)', opts)

-- Comment
vim.keymap.set("n", "<leader>c", "<cmd> :lua require('Comment.api').toggle.linewise.current()<CR>", opts)
vim.keymap.set("v", "<leader>c", "<esc><cmd> :lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)

-- EasyAlign
vim.keymap.set("v", "<leader>a", ":EasyAlign<CR>", opts)

-- LSP
vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
vim.keymap.set("n", "ga", function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = false } end, opts)
vim.keymap.set("n", "<leader>k", function() vim.diagnostic.open_float({scope="line"}) end, opts)

-- Dap
vim.keymap.set("n", "<leader>q", function() require"dap".close() end, opts)
vim.keymap.set("n", "<leader>d", function() require"dapui".toggle({ reset = true }) end, opts)
vim.keymap.set("n", "<leader>b", function() require"dap".toggle_breakpoint() end, opts)
vim.keymap.set("n", "<leader>t", function() require"dap".terminate() end, opts)
vim.keymap.set("n", "<leader>e", function() require("dapui").eval() end, opts)
vim.keymap.set("n", "<C-c>", function() require"dap".continue() end, opts)
vim.keymap.set("n", "<C-s>", function() require"dap".step_into() end, opts)
vim.keymap.set("n", "<C-o>", function() require"dap".step_over() end, opts)

-- Trailblazer
vim.keymap.set("n", "m", function() require("plugins.trailblazer").new_mark() end, opts)
vim.keymap.set("n", "<C-l>", function() require("trailblazer").peek_move_previous_up() end, opts)
vim.keymap.set("n", "<C-k>", function() require("trailblazer").peek_move_next_down() end, opts)
vim.keymap.set("n", "<Esc>c", function() require("trailblazer").move_to_trail_mark_cursor() end, opts)
vim.keymap.set("n", "<Esc>b", function() require("trailblazer").track_back() end, opts)
vim.keymap.set("n", "<Esc>l", function() require("plugins.trailblazer").load_session() end, opts)
vim.keymap.set("n", "<Esc>s", function() require("plugins.trailblazer").save_all_sessions() end, opts)
vim.keymap.set("n", "<Esc>da", function() require("plugins.trailblazer").delete_all_marks() end, opts)
vim.keymap.set("n", "<Esc>ds", function() require("trailblazer").delete_trail_mark_stack(nil, false) end, opts)
vim.keymap.set("n", "<Esc>as", function() require("plugins.trailblazer").add_stack() end, opts)
vim.keymap.set("n", "<Esc>p", function() require("trailblazer").switch_to_previous_trail_mark_stack(nil, false) end, opts)
vim.keymap.set("n", "<Esc>n", function() require("trailblazer").switch_to_next_trail_mark_stack(nil, false) end, opts)
