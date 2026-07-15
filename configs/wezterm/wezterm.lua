local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.enable_wayland = true
config.default_prog = { "fish" }

config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Medium" },
    "Noto Color Emoji",
})
config.font_size = 14
config.line_height = 1.10
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
config.colors = {
    tab_bar = {
        background = "#10151b",
        inactive_tab_edge = "#10151b",
        active_tab = {
            bg_color = "#20252d",
            fg_color = "#d4d1c9",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#171d24",
            fg_color = "#7c8490",
        },
        inactive_tab_hover = {
            bg_color = "#20252d",
            fg_color = "#d4d1c9",
        },
        new_tab = {
            bg_color = "#10151b",
            fg_color = "#7c8490",
        },
        new_tab_hover = {
            bg_color = "#20252d",
            fg_color = "#d4d1c9",
        },
    },
}
config.window_frame = {
    active_titlebar_bg = "#10151b",
    inactive_titlebar_bg = "#10151b",
    active_titlebar_fg = "#d4d1c9",
    inactive_titlebar_fg = "#7c8490",
    button_bg = "#10151b",
    button_fg = "#7c8490",
    button_hover_bg = "#20252d",
    button_hover_fg = "#d4d1c9",
    font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Medium" }),
    font_size = 13,
}

config.window_background_opacity = 0.80
config.text_background_opacity = 1.0
config.window_decorations = "NONE"
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 36
config.show_new_tab_button_in_tab_bar = false
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
    left = 16,
    right = 16,
    top = 16,
    bottom = 16,
}

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

wezterm.on("update-right-status", function(window)
    local mode = window:active_key_table()
    if window:leader_is_active() then
        mode = "leader"
    end

    window:set_right_status(mode and (" " .. mode .. " ") or "")
end)

local function rename_tab(window, _, line)
    if line then
        window:active_tab():set_title(line)
    end
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
    local title = tab.tab_title
    if title == "" then
        title = tab.active_pane.title
    end
    title = title:gsub("^/home/lucho", "~")
    title = wezterm.truncate_right(title, math.max(8, max_width - 8))

    local bg = tab.is_active and "#20252d" or hover and "#20252d" or "#171d24"
    local fg = tab.is_active and "#d4d1c9" or hover and "#d4d1c9" or "#7c8490"

    local cells = {
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = "   " .. title .. "    " },
    }

    return cells
end)

config.keys = {
    { key = "n",     mods = "CTRL|SHIFT",  action = act.SpawnWindow },
    { key = "t",     mods = "CTRL",        action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w",     mods = "CTRL|SHIFT",  action = act.CloseCurrentTab({ confirm = false }) },
    { key = "+",     mods = "CTRL",        action = act.IncreaseFontSize },
    { key = "=",     mods = "CTRL",        action = act.IncreaseFontSize },
    { key = "-",     mods = "CTRL",        action = act.DecreaseFontSize },
    { key = "0",     mods = "CTRL",        action = act.ResetFontSize },
    { key = "Enter", mods = "SHIFT",       action = act.SendString("\n") },
    { key = "Enter", mods = "CTRL|SHIFT",  action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "Enter", mods = "CTRL|ALT",    action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "h",     mods = "CTRL|ALT",    action = act.ActivatePaneDirection("Left") },
    { key = "j",     mods = "CTRL|ALT",    action = act.ActivatePaneDirection("Down") },
    { key = "k",     mods = "CTRL|ALT",    action = act.ActivatePaneDirection("Up") },
    { key = "l",     mods = "CTRL|ALT",    action = act.ActivatePaneDirection("Right") },

    { key = "b",     mods = "LEADER|CTRL", action = act.SendKey({ key = "b", mods = "CTRL" }) },
    { key = "c",     mods = "LEADER",      action = act.SpawnTab("CurrentPaneDomain") },
    { key = "n",     mods = "LEADER",      action = act.ActivateTabRelative(1) },
    { key = "p",     mods = "LEADER",      action = act.ActivateTabRelative(-1) },
    { key = "1",     mods = "LEADER",      action = act.ActivateTab(0) },
    { key = "2",     mods = "LEADER",      action = act.ActivateTab(1) },
    { key = "3",     mods = "LEADER",      action = act.ActivateTab(2) },
    { key = "4",     mods = "LEADER",      action = act.ActivateTab(3) },
    { key = "5",     mods = "LEADER",      action = act.ActivateTab(4) },
    { key = "6",     mods = "LEADER",      action = act.ActivateTab(5) },
    { key = "7",     mods = "LEADER",      action = act.ActivateTab(6) },
    { key = "8",     mods = "LEADER",      action = act.ActivateTab(7) },
    { key = "9",     mods = "LEADER",      action = act.ActivateTab(-1) },
    {
        key = ",",
        mods = "LEADER",
        action = act.PromptInputLine({
            description = "Rename tab",
            action = wezterm.action_callback(rename_tab),
        })
    },

    { key = "|",     mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "\\",    mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "-",     mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "x",     mods = "LEADER",       action = act.CloseCurrentPane({ confirm = false }) },
    { key = "z",     mods = "LEADER",       action = act.TogglePaneZoomState },
    { key = "[",     mods = "LEADER",       action = act.ActivateCopyMode },
    { key = "f",     mods = "LEADER",       action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "Space", mods = "LEADER",       action = act.ActivateCommandPalette },
    { key = "q",     mods = "LEADER",       action = act.PaneSelect({ mode = "Activate" }) },
    { key = "h",     mods = "LEADER",       action = act.ActivatePaneDirection("Left") },
    { key = "j",     mods = "LEADER",       action = act.ActivatePaneDirection("Down") },
    { key = "k",     mods = "LEADER",       action = act.ActivatePaneDirection("Up") },
    { key = "l",     mods = "LEADER",       action = act.ActivatePaneDirection("Right") },
    {
        key = "r",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "resize_pane",
            one_shot = false,
        })
    },
}

config.key_tables = {
    resize_pane = {
        { key = "h",          action = act.AdjustPaneSize({ "Left", 3 }) },
        { key = "j",          action = act.AdjustPaneSize({ "Down", 3 }) },
        { key = "k",          action = act.AdjustPaneSize({ "Up", 3 }) },
        { key = "l",          action = act.AdjustPaneSize({ "Right", 3 }) },
        { key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 3 }) },
        { key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 3 }) },
        { key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 3 }) },
        { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 3 }) },
        { key = "Escape",     action = "PopKeyTable" },
        { key = "q",          action = "PopKeyTable" },
    },
}

return config
