local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte
config.default_domain = 'WSL:NixOS'
config.window_background_opacity = 0.93



config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"
config.adjust_window_size_when_changing_font_size = false

config.window_padding = {
  left = 1,
  right = 1,
  top = 0,
  bottom = 0,
}

config.serial_ports = {
  {
    name = 'COM4',
    baud = 115200,
  },
}

local wsl_domains = wezterm.default_wsl_domains()

for _, dom in ipairs(wsl_domains) do
  dom.default_cwd = "~"
end

config.wsl_domains = wsl_domains
config.default_domain = "WSL:NixOS"
config.default_prog = { "wsl.exe" }

return config
