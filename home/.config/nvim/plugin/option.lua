vim.g.do_filetype_lua = 1

vim.g.python3_host_prog = "/usr/bin/python3"
vim.opt.number = true
vim.opt.relativenumber = true
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
-- it treat 2 space as <TAB> in file
vim.opt.tabstop = 2
-- it treat 2 space in editing file
vim.opt.softtabstop = 2
-- it treat 2 space on indent
vim.opt.shiftwidth = 2
-- round shiftwidth x times in indent lines
vim.opt.shiftround = true
-- maximum show up complement pop up menu items
-- default show up as much as possible (0 variable)
vim.opt.pumheight = 10
-- Enables pseudo-transparency for the |popup-menu|. (default 0)
vim.opt.pumblend = 15
vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
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
-- Defines the default border style of floating windows
vim.o.winborder = "single"
-- don't always use snack's animate plugin
vim.g.snacks_animate = false

vim.opt.clipboard = "unnamedplus"
if vim.fn.has("wsl") == 1 then
	-- WSL: bridge to the Windows clipboard via win32yank (see
	-- profiles/wsl.sh, which installs it to /mnt/c/Tools/win32yank.exe).
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
elseif
	(vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil)
	and (vim.env.DISPLAY == nil or vim.env.DISPLAY == "")
	and (vim.env.WAYLAND_DISPLAY == nil or vim.env.WAYLAND_DISPLAY == "")
then
	-- SSH session with no real X/Wayland display to talk a local
	-- clipboard tool through (e.g. a plain-SSH Ubuntu Server box like
	-- god77, or SSHing into a Desktop-profile machine without `-X`
	-- forwarding).
	--
	-- Deliberately keyed on DISPLAY/WAYLAND_DISPLAY, not on whether
	-- xclip/xsel/wl-copy are *installed*: the desktop profile does
	-- install xclip + wl-clipboard (see packages/desktop.txt) for its
	-- normal local GUI login, where this branch must NOT fire (Neovim's
	-- own auto-detection already handles that case correctly, via a real
	-- DISPLAY). Keying on executable() alone would wrongly skip this
	-- branch on a Desktop machine reached by plain SSH (no forwarding):
	-- xclip would be *present* but unable to reach any display, and
	-- Neovim's own detection requires a real $DISPLAY before it will even
	-- try xclip -- so with an executable()-only check, both this branch
	-- and Neovim's fallback would decline, and clipboard=unnamedplus
	-- (below) would leave `y`/`p` silently broken the same way the
	-- desktop profile was broken before packages/desktop.txt got xclip.
	--
	-- The SSH_TTY/SSH_CONNECTION check matters too: both the OSC52 copy
	-- below and clipboard_bridge.paste only make sense over an actual SSH
	-- connection (OSC52 needs a terminal on the other end to receive the
	-- escape sequence; the bridge only has anything to talk to when
	-- Windows' RemoteForward tunnel exists, which is set up per-SSH-
	-- session). Without this check, this branch would also fire for a
	-- local login on god77's own console (no SSH, still no display) and
	-- silently misbehave instead of falling through to Neovim's normal
	-- "no clipboard tool" handling, which is the correct behavior there.
	--
	-- Copy ("y") uses OSC52: the terminal emulator itself receives the
	-- escape sequence and sets its own (local) clipboard. Windows
	-- Terminal and WezTerm both implement this write direction, so this
	-- half works today with no extra moving parts. Setting
	-- `clipboard=unnamedplus` above stops Neovim's own automatic OSC52
	-- detection from kicking in, so it's configured explicitly here
	-- instead of relying on that.
	--
	-- Paste ("+p / plain p, since clipboard=unnamedplus) can NOT use
	-- OSC52 -- this was tried and is a dead end, not a bug to fix later:
	--   - Windows Terminal (and WezTerm, and most modern terminals)
	--     deliberately never answers an OSC52 *read* query -- letting a
	--     remote program silently read the local clipboard is treated as
	--     a security hole by their maintainers -- so this would just
	--     hang for up to 10s and then time out, every single time.
	--   - Inside tmux it's worse than a plain hang: tmux intercepts the
	--     query itself and answers from its *own* paste-buffer list
	--     instead of relaying whatever the real terminal holds (it never
	--     forwards the terminal's answer back at all), so "+p could
	--     silently insert unrelated old text some tmux pane copied
	--     earlier instead of what was just Ctrl-C'd on Windows.
	-- Full writeup, including why switching terminals/multiplexers
	-- doesn't help either: docs/clipboard-bridge-design.md.
	--
	-- Instead, paste goes over a small dedicated TCP bridge
	-- (clipboard_bridge.lua <-> windows-host/clipboard-bridge.ps1,
	-- reached through the same ssh -R tunnel) that talks to the Windows
	-- clipboard directly instead of asking the terminal to relay it.
	local osc52 = require("vim.ui.clipboard.osc52")
	local bridge = require("clipboard_bridge")
	vim.g.clipboard = {
		name = "OSC52 copy + TCP bridge paste",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = bridge.paste, ["*"] = bridge.paste },
	}
end

local autocmd = vim.api.nvim_create_autocmd

-- not continue comment line
autocmd("BufEnter", {
	pattern = "*",
	-- command = "set fo-=c fo-=r fo-=o",
	command = "set fo=jql",
})

-- autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
-- 	desc = "Highlight the cursor line in the active window",
-- 	pattern = "*",
-- 	command = "setlocal cursorline",
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

autocmd("ColorScheme", {
	desc = "change split bar to visible color",
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#cdcbe0", bg = "NONE" })
		-- vim.api.nvim_set_hl(0, "BufferCurrent", { fg = "#c0caf5", bg = "#1b0e0e" })
	end,
})

-- can close q key with under filetype
autocmd("FileType", {
	desc = "can close the buffer only 'q' command",
	pattern = {
		"help",
		"man",
		"lazy",
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

-- autocmd({ "BufRead", "BufNewFile" }, {
-- 	desc = "disable diagnostic reference source file",
-- 	pattern = {
-- 		-- javascript
-- 		"*/node_modules/*",
--
-- 		-- dart with flutter
-- 		"*/.pub-cache/*",
-- 		"~/flutter/*",
--
-- 		-- python
-- 		"*/.venv/*",
-- 	},
-- 	callback = function()
-- 		vim.diagnostic.enable(false, { bufnr = 0 })
-- 	end,
-- })

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
-- 	pattern = { "*.md", "*.tex" },
-- 	command = "setlocal spell",
-- })

-- autocmd("FileType", {
-- 	pattern = { "rust", "svelte", "python" },
-- 	callback = function()
-- 		-- syntax highlighting, provided by Neovim
-- 		vim.treesitter.start()
-- 		-- folds, provided by Neovim
-- 		-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 		-- vim.wo.foldmethod = "expr"
-- 		-- indentation, provided by nvim-treesitter
-- 		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
-- 	end,
-- })

local augroup = vim.api.nvim_create_augroup("treesitter_setup", { clear = true })

autocmd("FileType", {
	group = augroup,
	pattern = { "*" },
	callback = function(ctx)
		local buf = ctx.buf
		local max_filesize = 200 * 1024
		local filename = vim.api.nvim_buf_get_name(buf)

		local ok, stats = pcall(vim.uv.fs_stat, filename)
		if ok and stats and stats.size > max_filesize then
			return
		end

		local ts_started = pcall(vim.treesitter.start, buf)
		if ts_started then
			-- vim.wo.foldmethod = "expr"
			-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

			pcall(function()
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end)
		end
	end,
})
