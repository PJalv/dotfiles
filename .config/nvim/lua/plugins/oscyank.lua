return {
  "ojroques/vim-oscyank",
  event = "VeryLazy", -- or "BufReadPost" if you want it earlier
  config = function()
    -- Automatically send yanked text to your local clipboard via OSC 52
    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        if vim.v.event.operator == "y" then
          -- Yanked register (empty string means default register)
          local reg = vim.v.event.regname
          -- If reg is empty, use '"' (the unnamed register)
          if reg == "" then reg = '"' end
          vim.cmd("OSCYankRegister " .. reg)
        end
      end,
    })
  end,
}
