return {
  "luckasRanarison/tailwind-tools.nvim",
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = {
    server = {
      override = false,
    },
    document_color = {
      enabled = true,
      kind = "inline",
      inline_symbol = "󰝤 ",
    },
    conceal = {
      enabled = true,
      symbol = "󱏿",
      highlight = { fg = "#38BDF8" },
    },
  }
}
