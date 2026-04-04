return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    "border-fused",
    winopts = {
      height = 0.85,
      width = 0.80,
      preview = {
        layout = "vertical",
        vertical = "down:45%",
      },
    },
    keymap = {
      builtin = {
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
      },
    },
  },
}
