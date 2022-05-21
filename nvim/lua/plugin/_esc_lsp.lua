
local coq = require 'coq'

local lsp = vim.lsp
local buf_keymap = vim.api.nvim_buf_set_keymap
local cmd = vim.cmd

vim.api.nvim_command 'hi link LightBulbFloatWin YellowFloat'
vim.api.nvim_command 'hi link LightBulbVirtualText YellowFloat'

local kind_symbols = {
  Text = '  ',
  Method = '  ',
  Function = '  ',
  Constructor = '  ',
  Field = '  ',
  Variable = '  ',
  Class = '  ',
  Interface = '  ',
  Module = '  ',
  Property = '  ',
  Unit = '  ',
  Value = '  ',
  Enum = '  ',
  Keyword = '  ',
  Snippet = '  ',
  Color = '  ',
  File = '  ',
  Reference = '  ',
  Folder = '  ',
  EnumMember = '  ',
  Constant = '  ',
  Struct = '  ',
  Event = '  ',
  Operator = '  ',
  TypeParameter = '  ',
}

local sign_define = vim.fn.sign_define
sign_define('DiagnosticsSignError', { text = '', numhl = 'RedSign' })
sign_define('DiagnosticsSignWarn', { text = '', numhl = 'YellowSign' })
sign_define('DiagnosticsSignInfo', { text = '', numhl = 'WhiteSign' })
sign_define('DiagnosticsSignHint', { text = '', numhl = 'BlueSign' })

lsp_status.config {
  kind_labes = kaind_symbols,
  select_symbol = function(cursor_pos, symbol)
    if symbol.valueRange then
      local value_range = {
        ['start'] = { character = 0, line = vim.fn.byte2line(symbol.valueRange[1]) },
        ['end'] = { character = 0, line = vim.fn.byte2line(symbol.valueRange[2]) },
      }

      return require('lsp-status/util').in_range(cursor_pos, value_range)
    end
  end,
  current_function = false,
}

lsp_status.register_progress()
trouble.setup()
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(lsp.diagnostic.on_publish_diagnostic, {
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
})

require('lsp_signature').setup { bind = true, handler_opts = { border = 'single' } }

-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- require("null-ls").setup({
--     -- you can reuse a shared lspconfig on_attach callback here
--     on_attach = function(client, bufnr)
--         if client.supports_method("textDocument/formatting") then
--             vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
--             vim.api.nvim_create_autocmd("BufWritePre", {
--                 group = augroup,
--                 buffer = bufnr,
--                 callback = function()
--                     -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
--                     vim.lsp.buf.format({ bufnr = bufnr })
--                     -- vim.lsp.buf.formatting_sync()
--                 end,
--             })
--         end
--     end,
-- })

local keymap_opts = { noremap = true, silent = true }
local function on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  buf_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', keymap_opts)
  buf_keymap('n', 'gd', '<cmd>lua require"telescope.builtin".lsp_definitions()<CR>', keymap_opts)
  buf_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', keymap_opts)
  buf_keymap('n', 'gi', '<cmd>lua require"telescope.builtin".lsp_implementations()<CR>', keymap_opts)
  buf_keymap('n', 'gS', '<cmd>lua vim.lsp.buf.signature_help()<CR>', keymap_opts)
  buf_keymap('n', 'gT', '<cmd>lua vim.lsp.buf.type_definition()<CR>', keymap_opts)
  buf_keymap('n', 'gr', '<cmd>lua require"telescope.builtin".lsp_references()<CR>', keymap_opts)
  buf_keymap('n', '<c-k>', '<cmd>lua vim.diagnostic.goto_next { float = true }<cr>', keymap_opts)
  buf_keymap('n', '<c-j>', '<cmd>lua vim.diagnostic.goto_prev { float = true }<cr>', keymap_opts)

  if client.server_capabilities.documentFormattingProvider then
    buf_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.format { async = true }<cr>', keymap_opts)
  end

  cmd 'augroup lsp_aucmds'
  if client.server_capabilities.documentHighlightProvider then
    cmd 'au CursorHold <buffer> lua vim.lsp.buf.document_highlight()'
    cmd 'au CursorMoved <buffer> lua vim.lsp.buf.clear_references()'
  end

  cmd 'au CursorHold,CursorHoldI <buffer> lua require"nvim-lightbulb".update_lightbulb {sign = {enabled = false}, virtual_text = {enabled = true, text = ""}, float = {enabled = true, text = "", win_opts = {winblend = 100, anchor = "NE"}}}'
  -- cmd 'au CursorHold,CursorHoldI <buffer> lua vim.diagnostic.open_float(0, { scope = "line" })'
  cmd 'augroup END'
end

vim.g.coq_settings = { auto_start = true }

local function prefer_null_ls_fmt(client)
  client.server_capabilities.documentHighlightProvider = false
  client.server_capabilities.documentFormattingProvider = false
  on_attach(client)
end

-- local servers = {
--   clangd = {
--     prefer_null_ls = true,
--     handlers = lsp_status.extension.clangd.setup(),
--     init_options = {
--       clangdFileStatus = true,
--       usePlaceholders = true,
--       completeUnimported = true,
--       semanticHighlighting = true,
--     },
--   },
--   perlpls = {
--     inc = { '/home/plum/perl5/lib/perl5/'},
--     perlcritic = { enabled = true, perlcritic = '~/.perlcriticrc' },
--     syntax = { enabled = true, perl = '/usr/bin/perl' },
--     perltidy = '~/.perltidyrc'
--   },
--   rust_analyzer = {},
--   tsserver = {},
--   vimls = {},
-- }
--
-- local client_capabilities = vim.lsp.protocol.make_client_capabilities()
-- client_capabilities.textDocument.completion.completionItem.snippetSupport = true
-- client_capabilities.textDocument.completion.completionItem.resolveSupport = {
--   properties = { 'documentation', 'detail', 'additionalTextEdits' },
-- }
--
-- client_capabilities.offsetEncoding = { 'utf-16' }
--
-- for server, config in pairs(servers) do
  -- if type(config) == 'function' then
  --   config = config()
  -- end
  --
  -- if config.prefer_null_ls then
  --   if config.on_attach then
  --     local old_on_attach = config.on_attach
  --     config.on_attach = function(client, bufnr)
  --       old_on_attach(client, bufnr)
  --       prefer_null_ls_fmt(client)
  --     end
  --   else
  --     config.on_attach = prefer_null_ls_fmt
  --   end
  -- else
  --   if config.on_attach then
  --     local old_on_attach = config.on_attach
  --     config.on_attach = function(client, bufnr)
  --       old_on_attach(client, bufnr)
  --       prefer_null_ls_fmt(client)
  --     end
  --   else
  --     config.on_attach = on_attach
  --   end
  -- end
  --
--   config.capabilities = vim.tbl_deep_extend(
--   'keep',
--   config.capabilities or {},
--   client_capabilities,
--   lsp_status.capabilities
--   )
--   lspconfig[server].setup(config)
-- end

-- easy way

local perlpls_config = {
  cmd = { '/usr/local/bin/pls' },
  settings = {
    inc = { '/home/plum/perl5/lib/perl5/'},
    perlcritic = { enabled = true, perlcritic = '~/.perlcriticrc' },
    syntax = { enabled = true, perl = '/usr/bin/perl' },
    perltidy = '~/.perltidyrc'
  }
}

lspconfig.perlpls.setup(perlpls_config)
-- lspconfig.perlpls.setup {
--   coq.lsp_ensure_capabilities({
--     on_attach = on_attach,
--   }),
--   perlpls_config
-- }

  local servers = { 'clangd', 'rust_analyzer' }
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup(coq.lsp_ensure_capabilities({
      on_attach = on_attach
    }))
  end
-- null-ls setup
local null_fmt = null_ls.builtins.formatting
local null_diag = null_ls.builtins.diagnostics
local null_act = null_ls.builtins.code_actions
null_ls.setup {
  sources = {
    null_diag.chktex,
    -- null_diag.cppcheck,
    -- null_diag.proselint,
    -- null_diag.pylint,
    -- null_diag.selene,
    null_diag.shellcheck,
    -- null_diag.teal,
    -- null_diag.vale,
    -- null_diag.vint,
    -- null_diag.write_good.with { filetypes = { 'markdown', 'tex' } },
    null_fmt.clang_format,
    -- null_fmt.cmake_format,
    null_fmt.isort,
    -- null_fmt.prettier,
    null_fmt.rustfmt,
    -- null_fmt.shfmt,
    -- null_fmt.stylua,
    -- null_fmt.trim_whitespace,
    -- null_fmt.yapf,
    -- null_fmt.black
    -- null_act.gitsigns,
    null_act.refactoring.with { filetypes = { 'javascript', 'typescript', 'lua', 'python', 'c', 'cpp' } },
  },
  on_attach = on_attach,
}


-- working below
local lspconfig = require 'lspconfig'

local opts = { noremap=true, silent=true }
local buf_keymap = vim.api.nvim_buf_set_keymap

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  buf_keymap(bufnr, 'n', '<c-k>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_keymap(bufnr, 'n', '<c-j>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
end

local servers = { 'rust_analyzer', 'clangd', 'perlpls' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
  }
end
