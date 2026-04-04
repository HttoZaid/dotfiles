return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300 
  end,
  opts = {
    defaults = {
      ["<leader>f"] = { name = "+find" },
      ["<leader>s"] = { name = "+session" },
      ["<leader>t"] = { name = "+terminal" },
      ["<leader>d"] = { name = "+diagnostics" },
    },
  },
}