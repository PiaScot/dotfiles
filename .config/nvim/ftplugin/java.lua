local function jdtls_setup()
	local jdtls_setup = require("jdtls.setup")
	local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
	local root_dir = jdtls_setup.find_root(root_markers)
	if not root_dir then
		return
	end

	local home = os.getenv("HOME")
	local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls"
	local config_dir = jdtls_path .. "/config_linux"
	local launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
	local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
	local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

	local capab = vim.lsp.protocol.make_client_capabilities()
	local capabilities = require("blink.cmp").get_lsp_capabilities(capab)
	local java21_bin = "/usr/lib/jvm/java-21-openjdk-amd64/bin/java"
	local java17_home = "/usr/lib/jvm/java-17-openjdk-amd64"

	local config = {
		cmd = {
			java21_bin,
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xmx1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			launcher_path,
			"-configuration",
			config_dir,
			"-data",
			workspace_dir,
		},
		root_dir = root_dir,
		capabilities = capabilities,
		settings = {
			java = {
				configuration = {
					runtimes = {
						{
							name = "JavaSE-21",
							path = "/usr/lib/jvm/java-21-openjdk-amd64",
						},
						{
							name = "JavaSE-17",
							path = java17_home,
							default = true,
						},
					},
				},
				import = {
					gradle = { enabled = true },
					maven = { enabled = true },
				},
				signatureHelp = { enabled = true },
			},
		},
		init_options = {
			bundles = {},
			extendedClientCapabilities = jdtls_setup.extendedClientCapabilities,
		},
	}

	jdtls_setup.start_or_attach(config)
end

jdtls_setup()
-- it treat 2 space as <TAB> in file
vim.opt.tabstop = 2
-- it treat 2 space in editing file
vim.opt.softtabstop = 2
-- it treat 2 space on indent
vim.opt.shiftwidth = 2
