# 🌓 auto-gnome-theme.nvim

A simple, zero-polling Neovim plugin to automatically switch your colorscheme and background based on the Gnome system's light/dark mode preference.

It utilizes `gsettings monitor` to listen for system events, ensuring **instantaneous** and **resource-efficient** theme switching.

---

## Prerequisites

This plugin is specifically designed for the **Gnome** desktop environment (or any environment that exposes the theme setting via `gsettings`).

## Installation

### Using `lazy.nvim`

```lua
{
    "itsfernn/auto-gnome-theme.nvim",
  -- Ensure your chosen themes are installed!
  dependencies = { 
    -- "folke/tokyonight.nvim", 
    "rose-pine/neovim",
  },
  
  -- Configuration runs after the plugin is loaded
  config = function()
    require("auto-gnome-theme").setup({
      -- See Configuration section below
      theme = "rose-pine"
      -- dark_theme = "tokyonight",
      -- light_theme = "rose-pine",
    })
  end,
}
````

-----

## Configuration

The `setup()` function accepts a table with theme configuration.

### 1\. Single Theme Switching
Some themes like `rose-pine` already have both a light and dark theme. In this case the theme is only loaded on startup and only the `vim.o.background` is set dynamically.

```lua
require("auto-gnome-theme").setup({
  theme = "rose-pine", -- Applies Rose Pine for both dark and light mode
})
-- When the system is dark, vim.o.background is set to 'dark', and vice versa.
```

### 2\. Dual Theme Switching

You can also specify two entierly different colorschemes for light and dark modes. 

```lua
require("auto-gnome-theme").setup({
  dark_theme = "tokyonight",   -- Applies only when system is in Dark Mode
  light_theme = "catppuccin",  -- Applies only when system is in Light Mode
})
```

Here’s a concise note you can add to the README to explain the relevance of your plugin in light of the new Neovim and tmux features:

---

## Note
Recent versions of Neovim (see [commit d460928](https://github.com/neovim/neovim/commit/d460928263d0ff53283f301dfcb85f5b6e17d2ac)) now support automatic theme switching based on the terminal’s light/dark mode (if your terminal supports it). However, `auto-gnome-theme.nvim` still offers some advantages:
- **Granular control**: choose entirely different themes for light and dark modes, or use themes that have seperate dark / light themes.
- **No flashing colors on startup** when using a light theme.

