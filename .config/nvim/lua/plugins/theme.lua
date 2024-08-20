return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = function()
      return {
        styles = {
          transparency = true,
          bold = false,
        },
      }
    end,
  },
  { "ellisonleao/gruvbox.nvim", config = true, opts = {
    transparent_mode = true,
  } },
}
