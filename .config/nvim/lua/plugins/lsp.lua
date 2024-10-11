local function find_compile_commands_dir()
  local root = vim.fn.getcwd()
  local paths = { root, root .. "/build", root .. "/out", root .. "/cmake-build" }

  for _, path in ipairs(paths) do
    if vim.fn.filereadable(path .. "/compile_commands.json") == 1 then
      return path
    end
  end
  return root -- Fallback to root if not found
end

return {

  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = false },
      ---@type lspconfig.options
      servers = {
      },
    },
  },
  require("lspconfig").clangd.setup({
    cmd = { "clangd", "--compile-commands-dir=" .. find_compile_commands_dir() },
  }),
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
}
