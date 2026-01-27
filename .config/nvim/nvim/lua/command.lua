local cmd = vim.cmd

cmd([[command! Nvimrc :e ~/.config/nvim/init.lua]])
cmd([[command! Toml :e ~/.config/nvim/lua/plugins.lua]])

-- Custom command to reload the entire nvim config
local function reload_config()
  -- Reload all our custom modules inside 'lua/' by clearing them from the package cache
  for key in pairs(package.loaded) do
    if key:match("^plugins") or key:match("^colorscheme") or key:match("^command") or key:match("^keymap") or key:match("^lazy_nvim") or key:match("^option") then
      package.loaded[key] = nil
    end
  end

  -- Re-source the entry point of the config
  cmd([[source ~/.config/nvim/init.lua]])
  vim.notify("Nvim config reloaded!", vim.log.levels.INFO, { title = "Config" })
end

cmd([[command! ReloadConfig lua reload_config()]])
