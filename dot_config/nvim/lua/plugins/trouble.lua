return {
    "folke/trouble.nvim",
    opts = {
        auto_close = true,
        auto_open = true,
        modes = {
            diagnostics = {
                groups = {
                    { "filename", format = "{file_icon} {basename:Title} {count}" },
                },
            },
        },
    },
    config = function()
        -- vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        --     callback = function()
        --         vim.cmd([[Trouble qflist open]])
        --     end,
        -- })
    end,
}
