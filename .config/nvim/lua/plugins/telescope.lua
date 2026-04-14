return {

  "nvim-telescope/telescope.nvim",

  opts = function()
    local actions = require("telescope.actions")

    local action_state = require("telescope.actions.state")

    -- Function to add glob filter for file finder (supports multiple patterns)

    local function add_file_glob_filter(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)

      local prompt = picker:_get_prompt()

      prompt = prompt:gsub("[%z\1-\31]", ""):gsub("%s+$", "")

      actions.close(prompt_bufnr)

      vim.schedule(function()
        local glob_input = vim.fn.input("Glob filters (space-separated, e.g., .c !.mib): ")

        if glob_input and glob_input ~= "" then
          -- Parse multiple glob patterns

          local globs = {}

          for pattern in glob_input:gmatch("%S+") do
            table.insert(globs, "-g")

            table.insert(globs, pattern)
          end

          -- Build find_command with all glob patterns

          local find_command = { "rg", "--files", "--color", "never" }

          for _, g in ipairs(globs) do
            table.insert(find_command, g)
          end

          require("telescope.builtin").find_files({

            default_text = prompt,

            find_command = find_command,

          })
        else
          require("telescope.builtin").find_files({

            default_text = prompt,

          })
        end

        vim.defer_fn(function()
          vim.cmd("startinsert")
        end, 50)
      end)
    end

    -- Function to add glob filter for live_grep (supports multiple patterns)

    local function add_glob_filter(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)

      local prompt = picker:_get_prompt()

      prompt = prompt:gsub("[%z\1-\31]", ""):gsub("%s+$", "")

      actions.close(prompt_bufnr)

      vim.schedule(function()
        local glob_input = vim.fn.input("Glob filters (space-separated, e.g., .c !.mib): ")

        if glob_input and glob_input ~= "" then
          -- Parse multiple glob patterns

          local additional_args = {}

          for pattern in glob_input:gmatch("%S+") do
            table.insert(additional_args, "--glob")

            table.insert(additional_args, pattern)
          end

          require("telescope.builtin").live_grep({

            default_text = prompt,

            additional_args = function()
              return additional_args
            end,

          })
        else
          require("telescope.builtin").live_grep({

            default_text = prompt,

          })
        end

        vim.defer_fn(function()
          vim.cmd("startinsert")
        end, 50)
      end)
    end

    return {

      defaults = {

        mappings = {

          i = {

            ["<C-g>"] = add_glob_filter,

          },

          n = {

            ["<C-g>"] = add_glob_filter,

          },

        },

      },

      pickers = {

        live_grep = {

          mappings = {

            i = { ["<C-g>"] = add_glob_filter },

            n = { ["<C-g>"] = add_glob_filter },

          },

        },

        find_files = {

          mappings = {

            i = { ["<C-g>"] = add_file_glob_filter },

            n = { ["<C-g>"] = add_file_glob_filter },

          },

        },

      },

    }
  end,

  keys = {

    -- Override default grep keymaps to use Telescope

    { "<leader>sg", "<cmd>Telescope live_grep<cr>",           desc = "Grep (Root Dir)" },

    { "<leader>sG", "<cmd>Telescope live_grep cwd=false<cr>", desc = "Grep (cwd)" },

  },

}
