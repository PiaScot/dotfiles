return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"leoluz/nvim-dap-go",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		require("dapui").setup()
		require("dap-go").setup()
		require("nvim-dap-virtual-text").setup()
		local dap = require("dap")

		dap.listeners.before["event_initialized"]["custom"] = function(session, body)
			require("dapui").open()
		end

		dap.listeners.before["vent_terminate"]["custom"] = function(session, body)
			require("dapui").close()
		end

		dap.configurations.go = {
			{
				type = "go",
				name = "Debug",
				request = "launch",
				program = "${file}",
			},
			{
				type = "go",
				name = "Debug test",
				request = "launch",
				mode = "test",
				program = "${file}",
			},
			{
				type = "go",
				name = "Debug test (go.mod)",
				request = "launch",
				mode = "test",
				program = "./${relativeFileDirname}",
			},
		}
	end,
}
