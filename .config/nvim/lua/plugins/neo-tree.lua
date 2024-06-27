return {
  "nvim-neo-tree/neo-tree.nvim",
  requires = { "3rd/image.nvim" },
  opts = {
    window = {
      width = 30,
    },
    filesystem = {
      window = {
        mappings = { ["<leader>p"] = "kitty_prev" },
      },
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          -- '.git',
          -- '.DS_Store',
          -- 'thumbs.db',
        },
        never_show = {},
      },
      commands = {
        kitty_prev = function(state)
          local node = state.tree:get_node()
          if node.type == "file" then
            require("image_preview").PreviewImage(node.path)
          end
        end,
      },
    },
  },
}
