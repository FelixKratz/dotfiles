require("jupynium").setup({
  -- Used when notebook is launched by using jupyter_command.
  -- If nil or "", it will open at the git directory of the current buffer,
  -- but still navigate to the directory of the current buffer. (e.g. localhost:8888/tree/path/to/buffer)
  notebook_dir = "/tmp",

  -- Open the Jupynium server if it is not already running
  -- which means that it will open the Selenium browser when you open this file.
  -- Related command :JupyniumStartAndAttachToServer
  auto_start_server = {
    enable = true,
    file_pattern = { "*.ju.*" },
  },

  -- Attach current nvim to the Jupynium server
  -- Without this step, you can't use :JupyniumStartSync
  -- Related command :JupyniumAttachToServer
  auto_attach_to_server = {
    enable = true,
    file_pattern = { "*.ju.*" },
  },

  -- Automatically open an Untitled.ipynb file on Notebook
  -- when you open a .ju.py file on nvim.
  -- Related command :JupyniumStartSync
  auto_start_sync = {
    enable = true,
    file_pattern = { "*.ju.*" },
  },

  -- Automatically keep filename.ipynb copy of filename.ju.py
  -- by downloading from the Jupyter Notebook server.
  -- WARNING: this will overwrite the file without asking
  -- Related command :JupyniumDownloadIpynb
  auto_download_ipynb = false,

  use_default_keybindings = false,
  textobjects = {
    use_default_keybindings = true,
  },
})

local augroup = vim.api.nvim_create_augroup("jupynium", { clear = false })

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = "*.ju.*",
  callback = function()
    local buf_id = vim.api.nvim_get_current_buf()
    vim.keymap.set({ "n", "x" }, "<C-x>", "<cmd>JupyniumExecuteSelectedCells<CR>", { buffer = buf_id })
    vim.keymap.set({ "n", "x" }, "<space>x", "<cmd>JupyniumExecuteSelectedCells<CR><cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<cr>", { buffer = buf_id })
    vim.keymap.set({ "n", "x" }, "<space>c", "<cmd>JupyniumClearSelectedCellsOutputs<CR>", { buffer = buf_id })
    vim.keymap.set({ "n", "x" }, "<space>S", "<cmd>JupyniumScrollToCell<cr>", { buffer = buf_id })
    vim.keymap.set({ "n", "x" }, "<space>T", "<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>", { buffer = buf_id })
    vim.keymap.set("", "<PageUp>", "<cmd>JupyniumScrollUp<cr>", { buffer = buf_id })
    vim.keymap.set("", "<PageDown>", "<cmd>JupyniumScrollDown<cr>", { buffer = buf_id })
  end,
  group = augroup,
})
