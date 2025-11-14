return {
  {
    "yetone/avante.nvim",

    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    enabled = false,
    opts = {
      debug = false,
      cursor_applying_provider = "fast",  -- In this example, use Groq for applying, but you can also use any provider you want.
      auto_suggestions_provider = "fast", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
      memory_summary_provider = "fast",   -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
      rag_service = {
        enabled = false,
        runner = "nix",
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,         -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
      },
      provider = "main",
      providers = {
        main = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v",
          api_key_name = "OPENROUTER_API_KEY",
          -- model = "anthropic/claude-sonnet-4",
          -- model = "deepseek/deepseek-chat-v3-0324",
          -- model = "google/gemini-2.5-flash",
          model = "z-ai/glm-4.5",
          -- model = "qwen/qwen3-coder:floor",
        },
        fast = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "google/gemini-2.5-flash-preview-05-20",
        },
      },
      web_search_engine = {
        provider = "tavily",
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
        debounce = 600,
        throttle = 600,
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
              embed_image_as_base64 = true,
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
          "MeanderingProgrammer/render-markdown.nvim",
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
    },
  },
}
