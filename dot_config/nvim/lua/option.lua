vim.g.do_filetype_lua = 1

vim.g.python3_host_prog = "/usr/bin/python3"
vim.opt.number = true
-- vim.opt.relativenumber = true
-- not distinguish search command(/) big character or small character
vim.opt.ignorecase = true
-- global statusline
vim.opt.laststatus = 1
-- wrap 80 width line
vim.opt.textwidth = 80
-- always focus cursor on middle center
vim.opt.scrolloff = 4
-- it is grace time to write disk from swap file the time has not input. default is 4000 so change to 300
vim.opt.updatetime = 300
-- always show sign column not number column
vim.opt.signcolumn = "yes:1"
-- use space instead of tab
vim.opt.expandtab = true
-- it treat 4 space as <TAB> in file
vim.opt.tabstop = 4
-- it treat 4 space in editing file
vim.opt.softtabstop = 4
-- it treat 4 space on indent
vim.opt.shiftwidth = 4
-- round shiftwidth x times in indent lines
vim.opt.shiftround = true
-- maximum show up complement pop up menu items
-- default show up as much as possible (0 variable)
vim.opt.pumheight = 10
-- Enables pseudo-transparency for the |popup-menu|. (default 0)
-- vim.opt.pumblend = 15
-- use 24-bit color in nvim
-- to be transparency background is :hi Normal guibg=NONE
vim.opt.termguicolors = true
-- allow cursor to wrap to next/prev line
vim.o.whichwrap = "h,l"
-- enable showing non-printing-character
-- such as [space],[tab],[newline],...
-- not using to no use indent_blankline
vim.opt.list = false
-- 	A comma-separated list of options for Insert mode completion
-- default: "menu,preview"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
-- don't syntax highlight lone line file
vim.o.synmaxcol = 1000

vim.o.clipboard = "unnamedplus"

if vim.fn.has("wsl") then
    vim.g.clipboard = {
        name = "wsl_clipboard",
        copy = {
            ["+"] = "/mnt/c/Tools/win32yank.exe -i",
            ["*"] = "/mnt/c/Tools/win32yank.exe -i",
        },
        paste = {
            ["+"] = "/mnt/c/Tools/win32yank.exe -o",
            ["*"] = "/mnt/c/Tools/win32yank.exe -o",
        },
        cache_enabled = 0,
    }
end

local autocmd = vim.api.nvim_create_autocmd

-- not continue comment line
autocmd("BufEnter", {
    pattern = "*",
    command = "set fo-=c fo-=r fo-=o",
})

-- autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
--     desc = "Highlight the cursor line in the active window",
--     pattern = "*",
--     command = "setlocal cursorline",
-- })

-- autocmd("WinLeave", {
--     desc = "Clear the cursor line highlight when leaving a window",
--     pattern = "*",
--     command = "setlocal nocursorline",
-- })

-- autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
--     desc = "Diaable Highlight the cursor line in the active window",
--     pattern = "*",
--     command = "highlight CursorLine guibg=NONE",
-- })

-- vim.api.nvim_create_autocmd("ColorScheme", {
--     pattern = "*",
--     callback = function()
--         vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#cdcbe0", bg = "NONE" })
--         -- vim.api.nvim_set_hl(0, "BufferCurrent", { fg = "#c0caf5", bg = "#1b0e0e" })
--     end,
-- })

-- can close q key with under filetype
autocmd("Filetype", {
    pattern = {
        "help",
        "man",
        "notify",
        "lspinfo",
        "null-ls-info",
        "startuptime",
        "TelescopePrompt",
        "qf",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

vim.api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    { pattern = "*/node_modules/*", command = "lua vim.diagnostic.disable(0)" }
)

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.md", "*.tex" },
    command = "setlocal spell",
})

-- VertSplit      xxx g

-- disable neovim background color
-- under options is enabled, the inactive windows is dimmed.

-- vim.cmd[[
--   augroup TransparentBG
--     autocmd!
--     autocmd Colorscheme * highlight Normal guibg=none
--     autocmd Colorscheme * highlight NonText ctermbg=none
--     autocmd Colorscheme * highlight LineNr ctermbg=none
--     autocmd Colorscheme * highlight Folded ctermbg=none
--     autocmd Colorscheme * highlight EndOfBuffer ctermbg=none
--   augroup END
-- ]]
