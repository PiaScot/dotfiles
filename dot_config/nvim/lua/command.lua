local cmd = vim.cmd

cmd([[command! Nvimrc :e ~/.config/nvim/init.vim]])
cmd([[command! Toml :e ~/.config/nvim/lua/plugin.lua]])

cmd([[command! PackerInstall packadd packer.nvim | lua require('plugins').install()]])
cmd([[command! PackerUpdate packadd packer.nvim | lua require('plugins').update()]])
cmd([[command! PackerSync packadd packer.nvim | lua require('plugins').sync()]])
cmd([[command! PackerClean packadd packer.nvim | lua require('plugins').clean()]])
cmd([[command! PackerCompile packadd packer.nvim | lua require('plugins').compile()]])
