return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup({
          ui = {
            border = "single",
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        })
      end,
    },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    { "hrsh7th/cmp-nvim-lsp" },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {
          "pyright",
          "lua_ls",
          "ruff",
          "tailwindcss",
          "gopls",
          "rust_analyzer",
          -- "deno_ls",
          "svelte",
          "ts_ls",
          "clangd",
        },
        automatic_installation = true,
      },
    },
    { "stevearc/dressing.nvim", config = true },
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = {
        "williamboman/mason.nvim",
      },
    },
  },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

    -- for nvim-ufo plugin
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    vim.lsp.config('*', {
      capabilities = capabilities
    })

    vim.diagnostic.config({
      virtual_text = false,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "✘",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.HINT] = "",
          [vim.diagnostic.severity.INFO] = "",
        },
      },
      underline = false,
      update_in_insert = false,
      severity_sort = false,
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
        winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
      },
    })
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gI", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<C-j>", function() vim.diagnostic.jump({ count = 1, float = true })() end, opts)
        vim.keymap.set("n", "<C-k>", function() vim.diagnostic.jump({ count = 1, float = true })() end, opts)
      end,
    })

    vim.lsp.config('lua_ls', {
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
              path ~= vim.fn.stdpath('config')
              and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
          then
            return
          end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using (most
            -- likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
            -- Tell the language server how to find Lua modules same way as Neovim
            -- (see `:h lua-module-load`)
            path = {
              '?.lua',
              'lua/?.lua',
              'lua/?/init.lua',
            },
          },
          diagnostics = {
            globals = { 'vim', 'require', 'os' },
          },
          workspace = {
            checkThirdParty = false,
            -- library = {
            -- vim.env.VIMRUNTIME,
            -- Depending on the usage, you might want to add additional paths
            -- here.
            -- '${3rd}/luv/library',
            -- '${3rd}/busted/library',
            -- },
            -- Or pull in all of 'runtimepath'.
            -- NOTE: this is a lot slower and will cause issues when working on
            -- your own configuration.
            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
            -- library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      settings = {
        Lua = {},
      },
    })
  end,
}
