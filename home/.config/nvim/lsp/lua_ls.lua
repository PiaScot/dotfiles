return {
  settings = {
    Lua = {
      hint = { enable = true },
      telementry = { enable = false },
      diagnostics = {
        globals = { 'vim', 'require', 'os' },
      },
      workspace = {
        checkThirdParty = false,
      }
    }
  }
}
