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

-- LSP capabilities with blink-cmp
-- local capabilities = require("blink.cmp").get_lsp_capabilities()

-- LSP capabilities with cmp
local capab = vim.lsp.protocol.make_client_capabilities()
local capabilities = require("cmp_nvim_lsp").default_capabilities(capab)
vim.env.JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-amd64"
local java_home = os.getenv("JAVA_HOME") .. "/bin/java"


local config = {
  cmd = {
    java_home,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher_path,
    "-configuration", config_dir,
    "-data", workspace_dir,
  },
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = os.getenv("JAVA_HOME")
          },
        },
      },
      import = {
        gradle = {
          enabled = true,
        },
        maven = {
          enabled = true,
        }
      },
      signatureHelp = { enabled = true },
    },
  },
  init_options = {
    bundles = {},
    extendedClientCapabilities = jdtls_setup.extendedClientCapabilities
  }
}

jdtls_setup.start_or_attach(config)
