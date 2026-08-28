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
}
