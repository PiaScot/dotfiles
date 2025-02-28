return {
    "mfussenegger/nvim-lint",
    dependencies = {
        "jay-babu/mason-null-ls.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "nvimtools/none-ls.nvim",
        },
    },
    config = function()
        local lint = require('lint')
        lint.linters_by_ft = {
            rust = { "clippy" },
            -- svelte = { "biomejs" },

        }

        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
