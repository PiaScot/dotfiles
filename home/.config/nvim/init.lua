vim.g.mapleader = "\\"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
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
				"helper",
				"spellfile_plugin",
				"matchit",
				"matchparen",
			},
		},
	},
})

-- vim.cmd([[colorscheme kanagawa]])
-- vim.cmd([[colorscheme tokyonight]])
vim.cmd([[colorscheme tokyonight-night]])
-- vim.cmd([[colorscheme ayu-dark]])
-- vim.cmd([[colorscheme nightfox]])

-- vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#FFFFFF" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2E3440" })
