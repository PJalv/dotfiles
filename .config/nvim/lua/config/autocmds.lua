-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
--
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.filetype == "zig" or vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
      vim.cmd.colorscheme("gruvbox")
      require("lualine").setup({ options = { theme = "gruvbox" } })
    else
      vim.cmd.colorscheme("tokyonight")
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end
  end,
})
