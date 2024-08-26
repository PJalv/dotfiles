return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        gopls = {},
      },
    },
    require("lspconfig").clangd.setup({
      cmd = { "/home/pjalv/utils/esp_clang/esp-clang/bin/clangd" },
    }),
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
}
