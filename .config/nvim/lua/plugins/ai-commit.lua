return {
    "vernette/ai-commit.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("ai-commit").setup({
            -- your configuration
      {
  model = "qwen/qwen-2.5-72b-instruct:free", -- default model
  auto_push = false, -- whether to automatically push after commit
}
        })
    end
}
