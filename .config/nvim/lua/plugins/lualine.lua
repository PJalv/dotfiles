return {

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { fmt = string.lower },
      sections = {

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
