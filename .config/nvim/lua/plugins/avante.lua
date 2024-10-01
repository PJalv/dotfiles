return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  opts = {
    provider = "openai",
    openai = {
      model = "gpt-4o-mini",
      api_key_name = "cmd:cat " .. os.getenv("HOME") .. "/theenv/openaiapi",
    },
    -- add any opts here
    windows = {
      sidebar_header = {
        rounded = false,
      },
    },
  },
  dependencies = {
    -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "echasnovski/mini.icons",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below is optional, make sure to setup it properly if you have lazy=true
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
