return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "reason",
      auto_suggestions_provider = "fast", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
      behaviour = {
        auto_suggestions = true,          -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,         -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
      },
      vendors = {
        ["reason"] = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          model = "deepseek/deepseek-r1-distill-qwen-32b",
          -- model = "google/gemini-flash-1.5-8b",

          max_tokens = 10000,
          -- optional
          api_key_name = "cmd:cat " .. os.getenv("HOME") .. "/theenv/openrouter",
        },
        ["fast"] = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          -- model = "openai/gpt-4o-mini",
          model = "qwen/qwen-2.5-7b-instruct",

          timeout = 10000, -- Timeout in milliseconds
          -- optional
          api_key_name = "cmd:cat " .. os.getenv("HOME") .. "/theenv/openrouter",
        },
      },
      mappings = {
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<C-l>",
          next = "<C-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      suggestion = {
        debounce = 1,
        throttle = 1,
      },
      -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
      build = "make",
      -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        {
          -- support for image pasting
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            -- recommended settings
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              -- required for Windows users
              use_absolute_path = true,
            },
          },
        },
        {
          -- Make sure to set this up properly if you have lazy=true
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
    },
  }, }
