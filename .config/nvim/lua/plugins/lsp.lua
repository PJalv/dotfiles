local function find_compile_commands_dir()
  local root = vim.fn.getcwd()
  local paths = { root, root .. "/build", root .. "/out", root .. "/cmake-build" }

  for _, path in ipairs(paths) do
    if vim.fn.filereadable(path .. "/compile_commands.json") == 1 then
      return path
    end
  end
  return nil
end

-- Only pass --compile-commands-dir when compile_commands.json exists.
-- When it doesn't, clangd auto-discovers compile_flags.txt and .clangd
-- by walking up from the source file. Passing --compile-commands-dir
-- with a directory that has no compile_commands.json prevents that
-- fallback and breaks compile_flags.txt-based projects (e.g. VPP).
local compile_dir = find_compile_commands_dir()
local clangd_cmd = { "clangd" }
if compile_dir then
  clangd_cmd = { "clangd", "--compile-commands-dir=" .. compile_dir }
end

return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        clangd = {
          cmd = clangd_cmd,
          filetypes = { "c", "cpp", "objc", "objcpp", "arduino" },
        },
        basedpyright = {
          settings = {
            basedpyright = {
              typeCheckingMode = "standard",
            },
          },
        },
        nixd = {},
        bashls = {},
        zls = {},
        gopls = {},
        ts_ls = {},
        yamlls = {},
        copilot = {},
      },
    },
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
}
