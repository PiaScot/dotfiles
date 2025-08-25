return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
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
      "folke/neodev.nvim",
      config = true,
    },
    {
      "williamboman/mason-lspconfig.nvim",
    },

    {
      "stevearc/dressing.nvim",
      config = true,
    },
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = {
        "williamboman/mason.nvim",
      },
    },
  },
  config = function()
    local lspconfig = require("lspconfig")


    require("lspconfig.ui.windows").default_options.border = "rounded"

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

    -- for nvim-ufo plugin
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true
    }
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

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
        vim.keymap.set("n", "K", function()
          vim.lsp.buf.hover({ border = "rounded" })
        end, opts)

        -- vim.keymap.set("i", "<C-h>", function()
        --   vim.lsp.buf.signature_help({ border = "rounded" })
        -- end, opts)

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gI", vim.lsp.buf.references, opts)

        vim.keymap.set("n", "<C-j>", function()
          vim.diagnostic.goto_next()
        end, opts)

        vim.keymap.set("n", "<C-k>", function()
          vim.diagnostic.goto_prev()
        end, opts)
      end,
    })

    require("mason-lspconfig").setup({
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
        -- "typos_lsp",
      },
      automatic_installation = true,
    })

    local is_node_dir = function()
      return lspconfig.util.root_pattern('package.json')(vim.fn.getcwd())
    end
    require("mason-lspconfig").setup({
      function(server_name)
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
        })
      end,

      ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostic = {
                globals = { "vim" },
              },
            },
          },
        })
      end,
      -- ["typos_lsp"] = function()
      --   lspconfig.typos_lsp.setup({
      --     on_attach = function(client, bufnr)
      --       local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      --       if ft == "help" or ft == "toggleterm" then
      --         client.stop(true)
      --       end
      --     end,
      --   })
      -- end,
      ["ts_ls"] = function()
        lspconfig.ts_ls.setup({
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
          capabilities = capabilities,
          root_markers = { "index.html", "tsconfig.json", "jsconfig.json", "package.json" },
          workspace_required = true,
        })
      end,
      ["gopls"] = function()
        local gopath = os.getenv("GOPATH")
        local settings = {
          deepCompletion = true,
          fuzzyMatching = true,
          completeUnimported = true,
          usePlaceholders = true,
        }

        if gopath then
          settings.directoryFilters = { "+" .. gopath .. "/pkg/mod/golang.org/x" }
        end

        lspconfig.gopls.setup({
          capabilities = capabilities,
          settings = settings,
        })
      end,
      ["ruff"] = function()
        lspconfig.ruff.setup({
          init_options = {
            settings = {
              interpreter = { ".venv/bin/python" },
            },
          },
        })
      end,
      ["pyright"] = function()
        lspconfig.pyright.setup({
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticsMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
              },
            },
          },
        })
      end,
    })
  end,
}
