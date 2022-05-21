
vim.opt.ruler = true
vim.opt.number = true
vim.opt.completeopt = "menuone,noselect"
vim.opt.swapfile = false
vim.opt.smartcase = true
vim.opt.laststatus = 2
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true

vim.opt.scrolloff = 8
vim.opt.showcmd = true
vim.opt.wildmenu = true
vim.opt.showmatch = true

vim.opt.signcolumn = "yes"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true

vim.opt.termguicolors = true
vim.opt.background = dark

local disabled_build_ins = {
	"netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_build_ins) do
	vim.g["loaded_" .. plugin] = 1
end


vim.g.clipboard = {
       name = clipboard,
       copy = {
	       ['+'] = '/mnt/c/Tools/win32yank/win32yank.exe -i --crlf',
	       ['*'] = '/mnt/c/Tools/win32yank/win32yank.exe -i --crlf',
        },
       paste = {
          ['+'] = '/mnt/c/Tools/win32yank/win32yank.exe -o --lf',
          ['*'] = '/mnt/c/Tools/win32yank/win32yank.exe -o --lf',
       },
       cache_enabled = 1,
}

vim.o.clipboard = vim.o.clipboard .. 'unnamedplus'
