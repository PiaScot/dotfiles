local deps_ok, dap_virtual_text, dapui, dapui_widgets, dap = pcall(function()
	return require("nvim-dap-virtual-text"), require("dapui"), require("dap.ui.widgets"), require("dap")
end)
if not deps_ok then
	return
end

dap_virtual_text.setup()
dapui.setup()

require("dapui").setup({
	-- icons = { expanded = "", collapsed = "" },
	layouts = {
		{
			elements = {
				{ id = "watches", size = 0.30 },
				{ id = "stacks", size = 0.25 },
				{ id = "breakpoints", size = 0.20 },
				{ id = "scopes", size = 0.30 },
			},
			size = 64,
			position = "left",
		},
		{
			elements = {
				"console",
				"repl",
			},
			size = 0.40,
			position = "bottom",
		},
	},
})

local map = vim.keymap.set

local function c(func, opts)
	return function()
		func(opts)
	end
end

map("n", "<leader>d.", c(dap.run_to_cursor))
map("n", "<leader>dJ", c(dap.down))
map("n", "<leader>dK", c(dap.up))
map("n", "<leader>dL", function()
	dap.list_breakpoints()
	vim.cmd.copen()
end)
map("n", "<leader>dX", function()
	dap.terminate()
	dapui.close()
end)
map("n", "<leader>da", c(dap.toggle_breakpoint))
map("n", "<leader>dc", c(dap.continue))
vim.api.nvim_set_keymap("n", "<F1>", ":DapStepOver<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F2>", ":DapStepInto<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<F3>", ":DapStepOut<CR>", { silent = true })
-- map("n", "<leader>dh", c(dap.step_back))
-- map("n", "<leader>dj", c(dap.step_into))
-- map("n", "<leader>dk", c(dap.step_out))
-- map("n", "<leader>dl", c(dap.step_over))
map("n", "<leader>dr", c(dap.run_last))
map("n", "<leader>dx", c(dap.clear_breakpoints))

map("v", "<M-e>", c(dapui.eval))
map("n", "<leader>d?", c(dapui_widgets.hover))

dap.listeners.after.event_initialized["dapui_config"] = c(dapui.open)
dap.listeners.after.event_loadedSource["dapui_config"] = c(dapui.open)

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "WarningMsg" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "MatchParen", linehl = "CursorLine" })

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		-- CHANGE THIS to your path!
		command = "/home/plum/.local/share/nvim/mason/bin/codelldb",
		args = { "--port", "${port}" },

		-- On windows you may have to uncomment this:
		-- detached = false,
	},
}

dap.configurations.rust = {
	{
		name = "Launch file",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}

local venv = os.getenv("VIRTUAL_ENV")

local command = nil
if venv ~= nil then
	command = string.format("%s/bin/python", venv)
else
	command = "/usr/bin/python3"
end

dap.adapters.python = {
	type = "executable",
	command = command,
	args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
	{
		-- The first three options are required by nvim-dap
		type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
		request = "launch",
		name = "Launch file",

		-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

		program = "${file}", -- This configuration will launch the current file if used.
		console = "externalTerminal",
		pythonPath = function()
			return command
		end,
	},
}
