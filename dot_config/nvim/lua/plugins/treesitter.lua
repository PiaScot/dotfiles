return {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPre",
    dependencies = {
        "hiphish/rainbow-delimiters.nvim",
        "JoosepAlviste/nvim-ts-context-commentstring",
        "nvim-treesitter/nvim-treesitter-textobjects",
        "RRethy/nvim-treesitter-textsubjects",
        "mfussenegger/nvim-dap",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        require("nvim-dap-virtual-text").setup({})
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "tsx",
                "typescript",
                "javascript",
                "html",
                "css",
                "vue",
                "astro",
                "svelte",
                "go",
                "c",
                "rust",
                "gitcommit",
                "graphql",
                "json",
                "json5",
                "lua",
                "markdown",
                "prisma",
                "vimdoc",
                "vim",
            },                     -- one of "all", or a list of languages
            sync_install = false,  -- install languages synchronously (only applied to `ensure_installed`)
            ignore_install = { "haskell" }, -- list of parsers to ignore installing
            highlight = {
                enable = false,
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100kb
                    local ok, stat = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stat and stat.size > max_filesize then
                        return true
                    end
                end,

                -- disable = { "c", "rust" },  -- list of language that will be disabled
                -- additional_vim_regex_highlighting = false,
            },

            incremental_selection = {
                enable = false,
                keymaps = {
                    init_selection = "<leader>gnn",
                    node_incremental = "<leader>gnr",
                    scope_incremental = "<leader>gne",
                    node_decremental = "<leader>gnt",
                },
            },

            indent = {
                enable = true,
            },

            -- context_commentstring = {
            -- 	enable = true,
            -- 	enable_autocmd = false,
            -- },

            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]]"] = "@function.outer",
                        ["]m"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]["] = "@function.outer",
                        ["]M"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[["] = "@function.outer",
                        ["[m"] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[]"] = "@function.outer",
                        ["[M"] = "@class.outer",
                    },
                },
                select = {
                    enable = true,

                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,

                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["~"] = "@parameter.inner",
                    },
                },
            },

            textsubjects = {
                enable = true,
                keymaps = {
                    ["<cr>"] = "textsubjects-smart", -- works in visual mode
                },
            },
        })
    end,
}
