-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

--------------------------------------------------
--- Appearence
--------------------------------------------------
config.color_scheme = "tokyonight"
config.font = wezterm.font_with_fallback({
    { family = "ZedMono Nerd Font Mono" },
    -- { family = "Iosevka Nerd Font Mono" },
    -- { family = "GoMono Nerd Font Mono" },
    -- { family = "JetBrainsMono Nerd Font" },

    "Noto Color Emoji",
    "Symbols Nerd Font Mono",
})

config.font_size = 11.0

---------------------------------------------------
--- Tab
---------------------------------------------------
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config)

config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

---------------------------------------------------
--- Keybindings
---------------------------------------------------
config.disable_default_key_bindings = true
config.leader = { key = "g", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
    { key = "c", mods = "LEADER",     action = act.SpawnTab("CurrentPaneDomain") },
    { key = "q", mods = "LEADER",     action = act.CloseCurrentTab({ confirm = true }) },
    { key = "n", mods = "LEADER",     action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER",     action = act.ActivateTabRelative(-1) },
    { key = "v", mods = "LEADER",     action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-", mods = "LEADER",     action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
    { key = "r", mods = "LEADER",     action = act.ReloadConfiguration },
    { key = "h", mods = "LEADER",     action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER",     action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER",     action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER",     action = act.ActivatePaneDirection("Right") },
    { key = "[", mods = "LEADER",     action = act.ActivateCopyMode },
    { key = "f", mods = "LEADER",     action = act.ScrollByPage(1) },
    { key = "b", mods = "LEADER",     action = act.ScrollByPage(-1) },
}

-----------------------------------------------------
--- Mouse
-----------------------------------------------------
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = act.PasteFrom("Clipboard"),
    },
}

-- and finally, return the configuration to wezterm
return config

