-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

-- Override gd to use native LSP instead of fzf-lua
-- First remove any existing gd mapping (pcall in case it doesn't exist yet)
pcall(vim.keymap.del, "n", "gd")
map("n", "gd", function()
  vim.lsp.buf.definition()
end, { desc = "Goto Definition (Native)", remap = false })

map("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Set gd for all LSP clients to use native definition
    vim.keymap.set("n", "gd", function()
      vim.lsp.buf.definition()
    end, {
      buffer = args.buf,
      desc = "Goto Definition (Native)",
    })

    -- Special handling for clangd
    if client.name == "clangd" then
      vim.keymap.set("n", "<leader>gd", "<cmd>ClangdGotoDefinition<cr>", {
        buffer = args.buf,
        desc = "Goto Definition (prefer .c)",
      })
    end
  end,
})

-- Delete/change to blackhole register (don't overwrite clipboard)

map({ "n", "v" }, "d", '"_d', { desc = "Delete without saving to clipboard" })

map({ "n", "v" }, "D", '"_D', { desc = "Delete line without saving to clipboard" })

map({ "n", "v" }, "c", '"_c', { desc = "Change without saving to clipboard" })

map({ "n", "v" }, "C", '"_C', { desc = "Change to end without saving to clipboard" })

map("n", "x", '"_x', { desc = "Delete character without saving to clipboard" })

map("n", "X", '"_X', { desc = "Delete character before without saving to clipboard" })

-- Cut (delete to system clipboard) - use <leader>d for cut operations

-- Note: DAP uses <leader>db, <leader>dc, etc. which don't collide with <leader>dd, <leader>dw

map({ "n", "v" }, "<leader>d", '"+d', { desc = "Cut (operator-pending)" })

map("n", "<leader>dd", '"+dd', { desc = "Cut line to system clipboard" })

map("n", "<leader>dw", '"+dw', { desc = "Cut word to system clipboard" })

map("n", "<leader>diw", '"+diw', { desc = "Cut inner word to system clipboard" })

map("n", "<leader>diW", '"+diW', { desc = "Cut inner WORD to system clipboard" })

map("n", "<leader>D", '"+D', { desc = "Cut to end of line" })


-- Paste in visual mode without yanking replaced text (blackhole register)

-- Use x mode (visual + select) to cover all visual modes

map("x", "p", '"_dP', { desc = "Paste without yanking replaced text" })

map("x", "P", '"_dP', { desc = "Paste before without yanking replaced text" })

-- Prevent ANY yank in visual mode by restoring register on exit

-- This handles Ctrl+Shift+V paste and any other automatic yanks

local saved_visual_reg = nil

vim.api.nvim_create_autocmd("ModeChanged", {

  pattern = "*:v",

  callback = function()
    saved_visual_reg = vim.fn.getreg('"')
  end,

})

vim.api.nvim_create_autocmd("ModeChanged", {

  pattern = "v:*",

  callback = function()
    if saved_visual_reg then
      vim.fn.setreg('"', saved_visual_reg)

      saved_visual_reg = nil
    end
  end,

})

-- Alternative: use <leader>v for explicit clipboard paste in visual mode

map("x", "<leader>v", '"_d"+P', { desc = "Paste from clipboard without yanking selection" })
