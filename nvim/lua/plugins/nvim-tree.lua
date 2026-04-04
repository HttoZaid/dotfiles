return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = false,

      update_focused_file = {
        enable = true,
        update_root = false,
      },

      filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
      },

      view = {
        width = 35,
        relativenumber = true,
        side = "left",
      },

      renderer = {
        highlight_git = true,
        indent_markers = { enable = true },
        icons = {
          glyphs = {
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "⌥",
              renamed = "➜",
              untracked = "★",
              deleted = "⊖",
              ignored = "◌",
            },
          },
        },
      },

      diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },

      filters = {
          dotfiles = false,
          custom = {
              "^%.git$",
              "node_modules",
              ".DS_Store"
            },
        },
        git = {
            ignore = false,
        },
    })
  end,
}
