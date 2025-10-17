return {
  'stevearc/conform.nvim',
  opts = {
    keys = {
      {
        -- Existing keymap for buffer formatting
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
      {
        -- New keymap for visual mode formatting
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        mode = "v",
        desc = "Format selection",
      },
    },
    formatters = {
      -- Custom clang-format with range support
      ["clang-format"] = {
        -- Override the built-in clang-format to add range support
        range_args = function(self, ctx)
          return {
            "--lines=" .. ctx.range.start[1] .. ":" .. ctx.range["end"][1]
          }
        end,
      },
      -- Your existing custom formatter
      lua_switch_case_formatter = {
        inherit = false,
        command = "lua",
        args = {
          os.getenv("HOME") .. "/.config/nvim/scripts/formatter_c.lua",
          "$FILENAME",
        },
        stdin = false,
        -- Add range support for your custom formatter too (optional)
        range_args = function(self, ctx)
          -- You could modify your lua script to accept line range arguments
          return {
            os.getenv("HOME") .. "/.config/nvim/scripts/formatter_c.lua",
            "$FILENAME",
            ctx.range.start[1],  -- start line
            ctx.range["end"][1], -- end line
          }
        end,
      },
    },
    formatters_by_ft = {
      c = {
        "clang-format",
        "lua_switch_case_formatter",
      },
      nix = { "alejandra" }
    },
  },
}
