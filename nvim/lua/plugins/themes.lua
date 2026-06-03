return {
  -- TokyoNight: Deep blue dark.
  { "folke/tokyonight.nvim", lazy = true },

  -- Cyberdream: Pure black. High contrast.
  { "scottmckendry/cyberdream.nvim", lazy = true },

  -- Kanagawa: Warm, muted dark.
  { "rebelot/kanagawa.nvim", lazy = true },

  -- Catppuccin: Pastel dark.
  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- Rose Pine: Vintage dark.
  { "rose-pine/neovim", name = "rose-pine", lazy = true },

  -- Gruvbox: Retro earthy dark.
  { "ellisonleao/gruvbox.nvim", lazy = true },

  -- Nightfox: Rich, saturated dark.
  { "EdenEast/nightfox.nvim", lazy = true },

  -- Oxocarbon: Minimalist. Pure black with vibrant accents.
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },

  -- OneDark: Classic Atom-style dark.
  { "navarasu/onedark.nvim", lazy = true },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
