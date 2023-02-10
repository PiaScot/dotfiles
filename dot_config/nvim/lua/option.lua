vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

vim.g.python3_host_prog = "/usr/bin/python3"

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
	"man",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
}

for _, plugin in pairs(disabled_build_ins) do
	vim.g["loaded_" .. plugin] = 1
end

vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.number = true
-- vim.opt.completeopt = "menuone,noselect"
vim.opt.swapfile = false
vim.opt.smartcase = true
vim.opt.laststatus = 2
-- vim.opt.hlsearch = true
-- vim.opt.incsearch = true
vim.opt.ignorecase = true

vim.opt.textwidth = 80
vim.opt.scrolloff = 8
vim.opt.showcmd = true
vim.opt.wildmenu = true
vim.opt.showmatch = true
vim.opt.synmaxcol = 3000
vim.opt.updatetime = 300
vim.opt.wildmode = "longest,full"
vim.g.mapleader = "\\"

vim.opt.signcolumn = "yes:1"
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true

vim.opt.pumheight = 10

vim.opt.termguicolors = true

-- vim.opt.clipboard = "unnamedplus"

if vim.fn.has("wsl") then
	vim.g.clipboard = {
		name = clipboard,
		copy = {
			["+"] = "/mnt/c/Tools/win32yank-x64/win32yank.exe -i",
			["*"] = "/mnt/c/Tools/win32yank-x64/win32yank.exe -i",
		},
		paste = {
			["+"] = "/mnt/c/Tools/win32yank-x64/win32yank.exe -o",
			["*"] = "/mnt/c/Tools/win32yank-x64/win32yank.exe -o",
		},
		cache_enabled = 1,
	}

	vim.o.clipboard = vim.o.clipboard .. "unnamedplus"
end

-- vim.opt.clipboard:append({ "unnamedplus" })
-- vim.cmd([[set clipboard+=unnamedplus]])
