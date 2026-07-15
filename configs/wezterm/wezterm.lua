local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_wayland = true
config.default_prog = { "fish" }

config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font Mono",
  "Noto Color Emoji",
})
config.font_size = 14
config.line_height = 1.0
config.cell_width = 1.0

config.color_schemes = {
  ["Ayu Dark"] = {
    foreground = "#b3b1ad",
    background = "#0f1419",
    cursor_bg = "#e6b450",
    cursor_fg = "#0f1419",
    cursor_border = "#e6b450",
    selection_bg = "#253340",
    selection_fg = "#b3b1ad",
    split = "#253340",
    ansi = {
      "#0f1419",
      "#f07178",
      "#b8cc52",
      "#e6b450",
      "#59c2ff",
      "#d2a6ff",
      "#95e6cb",
      "#b3b1ad",
    },
    brights = {
      "#4d5566",
      "#f07178",
      "#b8cc52",
      "#e6b450",
      "#59c2ff",
      "#d2a6ff",
      "#95e6cb",
      "#ffffff",
    },
  },
}
config.color_scheme = "Ayu Dark"

config.window_background_opacity = 0.80
config.text_background_opacity = 1.0
config.window_decorations = "NONE"
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.window_close_confirmation = "NeverPrompt"
config.audible_bell = "Disabled"
config.hide_mouse_cursor_when_typing = true
config.default_cursor_style = "BlinkingBlock"
config.scrollback_lines = 3023
config.inactive_pane_hsb = {
  saturation = 0.82,
  brightness = 0.70,
}
config.window_padding = {
  left = 12,
  right = 12,
  top = 12,
  bottom = 12,
}

config.keys = {
  { key = "n", mods = "CTRL|SHIFT", action = wezterm.action.SpawnWindow },
  { key = "t", mods = "CTRL", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  { key = "+", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
  { key = "Enter", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "Enter", mods = "CTRL|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Right") },
}

return config
