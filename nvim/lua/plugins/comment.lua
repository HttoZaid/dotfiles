return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("Comment").setup({
      -- gcc: toggle line comment
      -- gbc: toggle block comment
      -- gc + motion: comment out a specific region (like gc9j)
      padding = true,
      sticky = true,
      ignore = "^$",
    })
  end,
}
