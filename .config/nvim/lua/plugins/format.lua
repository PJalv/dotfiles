return {
  'stevearc/conform.nvim',
  opts = {
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    formatters = {
      -- Define your custom formatter for the Lua script
      lua_switch_case_formatter = {
        -- 'inherit = false' is likely not needed here since this is a
        -- completely new formatter definition unless you planned to
        -- override a built-in formatter with the same name.
        -- If you want this to *only* be your blank line script,
        -- and not merge with any potential future 'lua_switch_case_formatter'
        -- built into conform.nvim, you can include 'inherit = false'.
        -- For clarity as a custom script, let's include it.
        inherit = false,

        -- The command to run the script
        command = "lua",

        -- Arguments to pass to the command.
        -- The first argument to 'lua' should be the script path.
        -- Subsequent arguments are passed to the script's arg table.
        -- $FILENAME is a magic string replaced by conform.nvim with the current buffer's filename. [1]
        args = {
          -- The full path to your switch case blank line script
          os.getenv("HOME") .. "/.config/nvim/scripts/formatter_c.lua",
          "$FILENAME", -- Pass the current filename to the script
        },

        -- Your script modifies the file in place, it doesn't output to stdout.
        -- So, tell conform.nvim not to read from stdout.
        stdin = false, -- The script doesn't take input from stdin
        -- to_stdout = false, -- Not needed if stdin=false, but good to be explicit
        -- This tells conform.nvim that the script will modify the file directly
        -- by not reading the formatted content back from stdout.

        -- You can add other options if necessary, though not required for this script:
        -- cwd = require("conform.util").root_file({ ".git", ".hg", ".vscode" }), -- Run from project root
        -- condition = function(self, ctx) return true end, -- Always run for C files
        -- exit_codes = { 0 }, -- What exit codes mean success
      },
    },

    formatters_by_ft = {
      -- ... other filetype configurations

      -- Apply your custom formatter to C files
      c = {
        -- You can list other formatters like 'clang-format' first
        -- conform will run formatters sequentially in the order listed here
        "clang-format",
        -- Then add your custom script formatter
        "lua_switch_case_formatter",
      },

      -- ... other filetype configurations
    },

  }
}
