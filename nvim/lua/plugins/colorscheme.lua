return {
  {
    "HttoZaid/mesopic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("mesopic").setup({})
      vim.cmd.colorscheme("mesopic")
    end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mesopic",
    },
  },
}
