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
            config = function()
                require("mason-lspconfig").setup({
                    ensure_installed = {
                        "pyright",
                        "lua_ls",
                        "tailwindcss",
                        "ts_ls",
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
            "nvimdev/lspsaga.nvim",
            config = function()
                require("lspsaga").setup({
                    ui = {},
                    lightbulb = {
                        enable = false,
                    },
                    outline = {
                        win_width = 50,
                    },
                })
            end,
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
        -- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
        -- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

        -- local capabilities = vim.tbl_deep_extend("force",
        --     vim.lsp.protocol.make_client_capabilities(),
        --     require('cmp_nvim_lsp').default_capabilities()
        -- )
        -- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false


        -- local capabilities
        -- do
        --     local default_capabilities = vim.lsp.protocol.make_client_capabilities()
        --     capabilities = {
        --         offsetEncoding = "utf-8",
        --         textDocument = {
        --             completion = {
        --                 completionItem = {
        --                     snippetSupport = true,
        --                 },
        --             },
        --             codeAction = {
        --                 resolveSupport = {
        --                     properties = vim.list_extend(
        --                         default_capabilities.textDocument.codeAction.resolveSupport.properties,
        --                         {
        --                             "documentation",
        --                             "detail",
        --                             "additionalTextEdits",
        --                         }
        --                     ),
        --                 },
        --             },
        --         },
        --     }
        -- end

        vim.diagnostic.config({
            virtual_text = false,
            signs = true,
            underline = false,
            update_in_insert = false,
            severity_sort = false,
            float = { border = "single" },
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function(ev)
                local bufmap = function(mode, lhs, rhs)
                    local bufopts = { noremap = true, silent = true, buffer = ev.buf }
                    vim.keymap.set(mode, lhs, rhs, bufopts)
                end

                bufmap("n", "K", "<cmd>Lspsaga hover_doc<cr>")
                bufmap("n", "gd", "<cmd>Lspsaga goto_definition<cr>")
                bufmap("n", "gy", "<cmd>Lspsaga finder<cr>")
                bufmap("n", "gr", "<cmd>Lspsaga rename<cr>")
                bufmap("n", "\\o", "<cmd>Lspsaga outline<cr>")

                bufmap("n", "<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<cr>")
                bufmap("n", "<C-j>", "<cmd>Lspsaga diagnostic_jump_next<cr>")
            end,
        })

        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },
            },
        })

        require("mason-lspconfig").setup_handlers({
            function(name)
                lspconfig[name].setup({
                    -- on_attach = function(_, bufnr)
                    --     -- client.handlers["textDocument/publishDiagnostics"] = function() end
                    --     -- client.server_capabilities.documentFormattingProvider = false
                    --     vim.api.nvim_create_autocmd("BufWritePre", {
                    --         buffer = bufnr,
                    --         callback = function()
                    --             vim.lsp.buf.code_action({
                    --                 apply = true,
                    --                 context = { only = { "quickfix" } }
                    --             })
                    --         end
                    --     })
                    -- end,
                    capabilities = capabilities,
                })
            end,
            ["lua_ls"] = function()
                lspconfig.lua_ls.setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false,
                            },
                        },
                    },
                })
            end,
            ["typos_lsp"] = function()
                lspconfig.typos_lsp.setup({})
            end,
            ["biome"] = function()
                lspconfig.biome.setup({})
            end,
            -- ["eslint"] = function()
            -- 	local nodePath = vim.fn.system("which node"):gsub("\n", "")
            -- 	lspconfig.eslint.setup({
            -- 		on_attach = function(client, bufnr)
            -- 			vim.api.nvim_create_autocmd("BufWritePre", {
            -- 				buffer = bufnr,
            -- 				command = "EslintFixAll",
            -- 			})
            -- 		end,
            -- 		codeAction = {
            -- 			disableRuleComment = {
            -- 				enable = true,
            -- 				location = "separateLine",
            -- 			},
            -- 			showDocumentation = {
            -- 				enable = true,
            -- 			},
            -- 		},
            -- 		codeActionOnSave = {
            -- 			enable = false,
            -- 			mode = "all",
            -- 		},
            -- 		experimental = {
            -- 			useFlatConfig = false,
            -- 		},
            -- 		format = true,
            -- 		nodePath = nodePath,
            -- 		onIgnoredFiles = "off",
            -- 		packageManager = "pnpm",
            -- 		problems = {
            -- 			shortenToSingleLine = false,
            -- 		},
            -- 		quiet = false,
            -- 		rulesCustomizations = {},
            -- 		run = "onType",
            -- 		useESLintClass = false,
            -- 		validate = "on",
            -- 		workingDirectory = {
            -- 			mode = "location",
            -- 		},
            -- 	})
            -- end,
            -- ["millet_ls"] = function()
            -- 	lspconfig.millet.setup({})
            -- end,
            -- ["gopls"] = function()
            --     local gopath = os.getenv("GOPATH")
            --     local settings = {
            --         deepCompletion = true,
            --         fuzzyMatching = true,
            --         completeUnimported = true,
            --         usePlaceholders = true,
            --     }

            --     if gopath then
            --         settings.directoryFilters = { "+" .. gopath .. "/pkg/mod/golang.org/x" }
            --     end

            --     lspconfig.gopls.setup({
            --         settings = settings,
            --     })
            -- end,
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
