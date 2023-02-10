require("sidebar-nvim").setup({
    disable_default_keybindings = 0,
    bindings = nil,
    open = true,
    side = "right",
    initial_width = 50,
    hide_statusline = true,
    update_interval = 500,
    sections = { "files", "buffers", "symbols" },
    section_separator = { "", "-----", "" },
    section_title_separator = { "" },
    containers = {
        attach_shell = "/bin/sh",
        show_all = true,
        interval = 5000,
    },
    -- datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
    -- todos = { ignored_paths = { "~" } },
})

require("sidebar-nvim").setup({
    bindings = {
        ["q"] = function()
            require("sidebar-nvim").close()
        end,
    },
})
