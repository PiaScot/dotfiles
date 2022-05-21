vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0
require 'impatient'
local g = vim.g
local cmd = vim.cmd
local o, wo, bo = vim.o, vim.wo, vim.bo
local utils = require 'config.utils'
local opt = utils.opt
local autocmd = utils.autocmd
local map = utils.map

g.python3_host_prog = '/usr/bin/python3'
g.node_host_prog = '/usr/local/bin/neovim-node-host'

-- Disable some built-in plugins we don't want
local disabled_built_ins = {
  'gzip',
  'man',
  'matchit',
  'matchparen',
  'shada_plugin',
  'tarPlugin',
  'tar',
  'zipPlugin',
  'zip',
  'netrwPlugin',
}

for i = 1, 10 do
    g['loaded_' .. disabled_built_ins[i]] = 1
end

local buffer = { o, bo }
local windows = { o, wo }
opt('textwidth', 80, buffer)
opt('scrolloff', 8)
opt('wildignore', '*.o,*~,*.pyc')
opt('wildmode', 'longest,full')
opt('lazyredraw', true)
opt('showmatch', true)
opt('ignorecase', true)
opt('smartcase', true)
opt('tabstop', 4, buffer)
opt('softtabstop', 0, buffer)
opt('expandtab', true, buffer)
opt('shiftwidth', 4, buffer)
opt('number', true, window)
opt('smartindent', true, buffer)
opt('laststatus', 3)
opt('showmode', false)
opt('shada', [['20,<50,s10,h,/100]])
opt('hidden', true)
opt('shortmess', o.shortmess .. 'c')
opt('guicursor', [[n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20]])
opt('updatetime', 500)
opt('conceallevel', 2, window)
opt('previewheight', 5)
opt('undofile', true, buffer)
opt('synmaxcol', 500, buffer)
opt('display', 'msgsep')
--opt('cursorline', true, window)
opt('modeline', false, buffer)
--opt('mouse', 'nivh')
opt('signcolumn', 'yes:1', window)

-- yank for wsl
g.clipboard = {
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
o.clipboard = o.clipboard .. 'unnamedplus'

-- Colorscheme
opt('termguicolors', true)
opt('background', 'dark')
cmd[[colorscheme kanagawa]]

-- Commands
cmd [[command! Nvimrc :e ~/.config/nvim/init.lua]]
cmd [[command! Toml :e ~/.config/nvim/lua/plugins.lua]]

cmd [[command! PackerInstall packadd packer.nvim | lua require('plugins').install()]]
cmd [[command! PackerUpdate packadd packer.nvim | lua require('plugins').update()]]
cmd [[command! PackerSync packadd packer.nvim | lua require('plugins').sync()]]
cmd [[command! PackerClean packadd packer.nvim | lua require('plugins').clean()]]
cmd [[command! PackerCompile packadd packer.nvim | lua require('plugins').compile()]]

-- Keybindings
local silent = { silent = true }

map('n', ';', ':')
map('n', '<C-p>', ':bprev<CR>', silent)
map('n', '<C-n>', ':bnext<CR>', silent)
map('n', 'ss', '<C-w>s', silent)
map('n', 'sv', '<C-w>v', silent)
map('n', 'sh', '<C-w>h', silent)
map('n', 'sj', '<C-w>j', silent)
map('n', 'sk', '<C-w>k', silent)
map('n', 'sl', '<C-w>l', silent)
map('n', 'sq', '<C-w>q', silent)
--map('n', '\\w', ':source ~/.config/nvim/init.lua', silent)
map('i', 'jj', '<ESC>', silent)
map('t', 'JJ', '<C-\\><C-n>', silent)

-- require'options'
-- require'commands'
-- require'keymaps'
--require'plugins'

--vim.cmd('colorscheme kanagawa')
