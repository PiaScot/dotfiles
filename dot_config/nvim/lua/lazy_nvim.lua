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


vim.opt.rtp:prepend(lazypath)

local lazy_opts = {
	change_detection = {
		notify = false,
	},
	ui = {
		size = { width = 0.7, height = 0.7 },
		border = "single",
		-- none or single or double or rounded or solid or shadow
		-- or array type that need 8-parameter or any divisor of eight
	}
}

require("lazy").setup("plugins", lazy_opts)
