return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim",
        "jay-babu/mason-null-ls.nvim",
        "folke/neodev.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local lspconfig = require("lspconfig")
        local util = lspconfig.util
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        require("lspconfig.ui.windows").default_options.border = "single"
        require("neodev").setup({})
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
        require("mason-lspconfig").setup({
            ensure_installed = {
                "pyright",
                "gopls",
                "rust_analyzer",
                "lua_ls",
                "clangd",
            },
            automatic_installation = true,
        })
        require("mason-null-ls").setup({
            ensure_installed = { "stylua", "gofmt", "gofumpt", "goimports", "shfmt" },
            automatic_installation = true,
        })

        local capabilities
        do
            local default_capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = {
                offsetEncoding = "utf-8",
                textDocument = {
                    completion = {
                        completionItem = {
                            snippetSupport = true,
                        },
                    },
                    codeAction = {
                        resolveSupport = {
                            properties = vim.list_extend(
                                default_capabilities.textDocument.codeAction.resolveSupport.properties,
                                {
                                    "documentation",
                                    "detail",
                                    "additionalTextEdits",
                                }
                            ),
                        },
                    },
                },
            }
        end

        util.default_config = vim.tbl_deep_extend("force", util.default_config, {
            capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                cmp_nvim_lsp.default_capabilities(capabilities)
            ),
        })

        -- require("mason-nvim-dap").setup({})

        vim.diagnostic.config({
            virtual_text = false,
            signs = true,
            underline = false,
            update_in_insert = false,
            severity_sort = false,
            -- float = { border = "single" },
        })
        -- vim.diagnostic.config = nil

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            callback = function()
                local bufmap = function(mode, lhs, rhs)
                    local opts = { buffer = true }
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
                bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
                bufmap("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
                bufmap("n", "gy", "<cmd>lua vim.lsp.buf.references()<cr>")
                bufmap("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
                bufmap("n", "<C-k>", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
                bufmap("n", "<C-j>", "<cmd>lua vim.diagnostic.goto_next()<cr>")
            end,
        })

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "single",
        })

        local sign = function(opts)
            vim.fn.sign_define(opts.name, {
                texthl = opts.name,
                text = opts.text,
                numhl = "",
            })
        end

        sign({ name = "DiagnosticSignError", text = "✘" })
        sign({ name = "DiagnosticSignWarn", text = "" })
        sign({ name = "DiagnosticSignHint", text = "" })
        sign({ name = "DiagnosticSignInfo", text = "" })

        require("mason-lspconfig").setup_handlers({
            function(name)
                lspconfig[name].setup({})
            end,
            ["lua_ls"] = function()
                lspconfig.lua_ls.setup({
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
                    settings = settings,
                })
            end,
            ["ruff_lsp"] = function()
                lspconfig.ruff_lsp.setup({
                    init_options = {
                        settings = {
                            args = {},
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
