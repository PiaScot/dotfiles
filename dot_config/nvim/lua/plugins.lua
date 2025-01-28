return {
    {
        "rebelot/kanagawa.nvim",
    },
    {
        "echasnovski/mini.icons",
        version = false,
    },
    {
        "phaazon/hop.nvim",
        branch = "v2",
        config = function()
            require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

            local keymap = vim.api.nvim_set_keymap
            keymap("", "f", "<cmd>HopChar1<CR>", {})
        end,
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = {
            "kkharji/sqlite.lua",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local builtin = require("telescope.builtin")
            require("telescope").load_extension("frecency")
            vim.keymap.set("n", "<leader>s", builtin.find_files, {})
            vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
            vim.keymap.set("n", "<leader>r", builtin.live_grep, {})
            vim.keymap.set("n", "<leader>f", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>")

            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                        },
                    },
                },
            })
        end,
    },
    {
        "tpope/vim-surround",
    },
    {
        "numToStr/Comment.nvim",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            require("ts_context_commentstring").setup({
                enable_autocmd = false,
            })
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                scope = { enabled = false },
            })
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },
}
