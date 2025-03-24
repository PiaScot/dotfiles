return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    -- "Saghen/blink.cmp",
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
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = {
            "pyright",
            "lua_ls",
            "tailwindcss",
            "gopls",
            "rust_analyzer",
            "biome",
            "svelte",
            "clangd",
            "denols",
            "typos_lsp",
          },
          automatic_installation = true,
        })
      end,
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
    require("lspconfig.ui.windows").default_options.border = "single"

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
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
      float = { border = "single" },
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover,
      {
        border = "single",
      }
    )

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(ev)
        local bufmap = function(mode, lhs, rhs)
          local bufopts = { noremap = true, silent = true, buffer = ev.buf }
          vim.keymap.set(mode, lhs, rhs, bufopts)
        end

        bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
        bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
        bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
        bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")
        bufmap("n", "gr", "<cmd>lua vim.lsp.buf.rename()<cr>")
        bufmap("n", "gI", "<cmd>lua vim.lsp.buf.references()<cr>")

        bufmap("n", "<C-j>", "<cmd>lua vim.diagnostic.goto_next()<cr>")
        bufmap("n", "<C-k>", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
      end,
    })

    local is_node_dir = function()
      return lspconfig.util.root_pattern('package.json', 'tsconfig.json')(vim.fn.getcwd())
    end

    require("mason-lspconfig").setup_handlers({
      function(name)
        -- if name == "tailwindcss" or name == "denols" then
        --   return
        -- end
        lspconfig[name].setup({
          capabilities = capabilities,
        })
      end,
      ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostic = {
                globals = { "vim" }
              }
            },
          },
        })
      end,
      ["typos_lsp"] = function()
        lspconfig.typos_lsp.setup({
          on_attach = function(client, bufnr)
            local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
            if ft == "help" then
              client.stop(true)
            end
          end
        })
      end,
      ["vtsls"] = function()
        lspconfig.vtsls.setup({
          capabilities = capabilities,
          root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json'),
          on_attach = function(client)
            if not is_node_dir() then
              client.stop(true)
            end
          end,
          single_file_support = false,
        })
      end,
      ["denols"] = function()
        lspconfig.denols.setup({
          capabilities = capabilities,
          on_attach = function(client)
            if is_node_dir() then
              client.stop(true)
            end
          end,
          init_options = {
            lint = true,
            unstable = true,
            suggest = {
              imports = {
                hosts = {
                  ["https://deno.land"] = true,
                  ["https://cdn.nest.land"] = true,
                  ["https://crux.land"] = true
                }
              }
            }
          }
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
      -- ["ruff_lsp"] = function()
      --     lspconfig.ruff_lsp.setup({
      --         init_options = {
      --             settings = {
      --                 args = {},
      --             },
      --         },
      --     })
      -- end,
      -- ["pyright"] = function()
      --     lspconfig.pyright.setup({
      --         settings = {
      --             python = {
      --                 analysis = {
      --                     autoSearchPaths = true,
      --                     diagnosticsMode = "openFilesOnly",
      --                     useLibraryCodeForTypes = true,
      --                 },
      --             },
      --         },
      --     })
      -- end,
      -- ["clangd"] = function()
      --     lspconfig.clangd.setup({
      --         offsetEncoding = "utf-8",
      --     })
      -- end,
      -- ["perlpls"] = function()
      -- 	lspconfig.perlpls.setup({
      -- 		settings = {
      -- 			perl = {
      -- 				perlcritic = {
      -- 					enable = false,
      -- 				},
      -- 				syntax = {
      -- 					enabled = true,
      -- 				},
      -- 			},
      -- 		},
      -- 	})
      -- end,
      -- ["rust_analyzer"] = function()
      -- 	rt.setup({
      -- 		assist = {
      -- 			importEnforceGranularity = true,
      -- 			importPrefix = "crate",
      -- 		},
      -- 		cargo = {
      -- 			allFeatures = true,
      -- 		},
      -- 		checkOnSave = {
      -- 			enable = true,
      -- 			command = "clippy",
      -- 		},
      -- 		-- rust-tools options
      -- 		tools = {
      -- 			autoSetHints = true,
      -- 			inlay_hints = {
      -- 				show_parameter_hints = true,
      -- 				parameter_hints_prefix = "",
      -- 				other_hints_prefix = "",
      -- 			},
      -- 		},
      -- 		-- dap = {
      -- 		-- 	adapter = {
      -- 		-- 		type = "server",
      -- 		-- 		command = "codelldb",
      -- 		-- 		name = "rt_lldb",
      -- 		-- 	},
      -- 		-- },
      -- 	})
      -- end,
    })
  end,
}
