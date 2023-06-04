vim.g.do_filetype_lua = 1

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
}

for _, plugin in pairs(disabled_build_ins) do
	vim.g["loaded_" .. plugin] = 1
end

vim.opt.number = true
-- vim.opt.relativenumber = true

-- not distinguish search command(/) big character or small character
vim.opt.ignorecase = true

-- always show status line
vim.opt.laststatus = 2

-- wrap 80 width line
vim.opt.textwidth = 80

-- always focus cursor on middle center
vim.opt.scrolloff = 999

-- default is 4000 so change to 300
-- it is grace time to write disk from swap file the time has not input
vim.opt.updatetime = 300

-- always show sign column not number column
vim.opt.signcolumn = "yes:1"

-- use space instead of space
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
vim.opt.pumblend = 10

-- use 24-bit color in nvim
-- to be transparency background is :hi Normal guibg=NONE
vim.opt.termguicolors = true

-- enable showing non-printing-character
-- such as [space],[tab],[newline],...
-- not using to no use indent_blankline
vim.opt.list = false

-- 	A comma-separated list of options for Insert mode completion
-- default: "menu,preview"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
		cache_enabled = 1,
	}
end

vim.o.clipboard = vim.o.clipboard .. "unnamedplus"

local autocmd = vim.api.nvim_create_autocmd

-- not continue comment line
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- jump to previous buffer line
autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

-- can close q key with under filetype
autocmd("Filetype", {
	pattern = {
		"help",
		"man",
		"notify",
		"lspinfo",
		"startuptime",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- highlight_yank but it is subtle...
-- vim.api.nvim_create_autocmd("TextYankPost", {
-- 	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
-- 	callback = function()
-- 		vim.highlight.on_yank()
-- 	end,
-- })
