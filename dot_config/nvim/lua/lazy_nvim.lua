local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

if vim.g.neovide then
    vim.o.guifont = "IosevkaTermSlab Nerd Font Mono:h11"
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    change_detection = {
        notify = false,
    },
    ui = {
        size = { width = 0.7, height = 0.7 },
        border = "single",
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "netrw",
                "netrwPlugin",
                "netrwSettings",
                "netrwFileHandlers",
                "gzip",
                "zip",
                "zipPlugin",
                "tar",
                "tarPlugin",
                "tohtml",
                "tutor",
                "getscript",
                "getscriptPlugin",
                "vimball",
                "vimballPlugin",
                "2html_plugin",
                "man",
                "logipat",
                "rrhelper",
                "spellfile_plugin",
                "matchit",
                "matchparen",
            },
        },
    },
})
