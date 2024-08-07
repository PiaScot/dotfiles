return {
    "romgrk/barbar.nvim",
    config = function()
        require("barbar").setup({

            exclude_ft = { "qf" },
            icons = {
                buffer_index = true,
                buffer_number = false,
                button = "",
                -- Enables / disables diagnostic symbols
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true },
                    [vim.diagnostic.severity.WARN] = { enabled = true },
                    [vim.diagnostic.severity.INFO] = { enabled = false },
                    [vim.diagnostic.severity.HINT] = { enabled = false },
                },
                gitsigns = {
                    added = { enabled = false, icon = "+" },
                    changed = { enabled = false, icon = "~" },
                    deleted = { enabled = false, icon = "-" },
                },
                separator = { left = "▎", right = "" },
                modified = { button = "●" },
                pinned = { button = "車", filename = true, separator = { right = "" } },
                alternate = { filetype = { enabled = false } },
                current = { buffer_index = true },
                inactive = { button = nil },
                visible = { modified = { buffer_number = false } },
            },
            -- Set the filetypes which barbar will offset itself for
            sidebar_filetypes = {
                -- Use the default values: {event = 'BufWinLeave', text = nil}
                -- NvimTree = { text = "File Explorer" },
                -- Or, specify the text used for the offset:
                -- undotree = { text = "undotree" },
                -- Or, specify the event which the sidebar executes when leaving:
                -- ["neo-tree"] = { event = "BufWipeout" },
                -- Or, specify both
                -- Outline = { event = "BufWinLeave", text = "symbols-outline" },
            },
        })
    end,
}
