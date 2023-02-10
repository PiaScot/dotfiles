local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.api.nvim_exec('silent! normal! g`"zv', false)
	end,
})

-- autocmd('Filetype', {
--     pattern = { 'rust' },
--     group = dispatch_for_rust,
--     desc = 'Dispatch config for rust filetype',
--     callback = function()
--         vim.b.dispatch = 'cargo run %'
--     end,
-- })
