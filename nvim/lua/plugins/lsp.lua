return {
  {
    "brenoprata10/nvim-highlight-colors",
    config = function()
      require("nvim-highlight-colors").setup({
        ---@usage 'background'|'foreground'|'virtual'
        render = "background",

        enable_hex = true,
        enable_short_hex = true,
        enable_rgb = false,
        enable_hsl = false,
        enable_var_usage = false,

        -- Exclude giant files.
        exclude_filetypes = { "lazy" },
        exclude_buftypes = { "terminal" },
      })
    end,
  },
  {
    "nvim-mini/mini.surround",
    version = false,
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },
}
