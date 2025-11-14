return {

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        lualine_x = {
          {
            function()
              local icon = " "
              local ok, copilot_status = pcall(require, "copilot.status")
              if not ok then return icon .. "off" end
              local status = copilot_status.data.status
              if status == "InProgress" then
                return icon .. "pending"
              elseif status == "Warning" then
                return icon .. "error"
              elseif status == "Normal" or status == "" then
                return icon .. "ok"
              else
                return icon .. status
              end
            end,
            color = { fg = "#6CC644" },
            cond = function()
              local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
              return #clients > 0
            end,
          },
        },
        lualine_z = {
          {
            'datetime',
            -- options: default, us, uk, iso, or your own format string ("%H:%M", etc..)
            style = "%H:%M:%S",
          }
        }
      }
    }
  } }
