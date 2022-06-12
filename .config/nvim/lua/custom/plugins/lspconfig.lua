local M = {}

local lspconfig = require "lspconfig"

M.setup_lsp = function(attach, capabilities)

  -- lspservers with default config
  local default_servers = { "bashls", "pyright",
  "texlab", "asm_lsp" }

  for _, lsp in ipairs(default_servers) do
    lspconfig[lsp].setup {
      on_attach = attach,
      capabilities = capabilities,
    }
  end

  -- lspservers with custom config
  lspconfig.ccls.setup {
    on_attach = attach,
    capabilities = capabilities,

    init_options = {
      cache = {
        directory = "/tmp/ccls-cache"
      },
    },
  }
end

return M
