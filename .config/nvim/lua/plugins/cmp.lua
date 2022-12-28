vim.opt.completeopt = "menuone,noselect"

local cmp = require("cmp")

local options = {
  window = {
    completion = {
      border = "rounded",
      side_padding = 1,
      winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
      zindex = 1001,
    },
    documentation = {
      border = "rounded",
      side_padding = 1,
      winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
      zindex = 1001,
    }
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = require 'lspkind'.cmp_format( { mode = "symbol_text" } ),
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
      else
        fallback()
      end
    end, {
    "i",
    "s",
  }),
  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif require("luasnip").jumpable(-1) then
      vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
    else
      fallback()
    end
  end, {
  "i",
  "s",
}),
   },
   sources = {
     { name = "luasnip" },
     { name = "nvim_lsp" },
     { name = "nvim_lua" },
     { name = "path" },
     { name = 'nvim_lsp_signature_help' },
   },
 }

 cmp.setup(options)
