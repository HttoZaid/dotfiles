return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local ts = require("nvim-treesitter")

    ts.install({
      "lua",
      "vim",
      "vimdoc",
      "query",
      "c",
      "cpp",
      "rust",
      "python",
      "go",
      "gomod",
      "gowork",
      "gosum",
      "javascript",
      "typescript",
      "tsx",
      "html",
      "css",
      "json",
      "yaml",
      "dart",
      "swift",
      "bash",
      "dockerfile",
      "markdown",
      "markdown_inline",
      "toml",
      "regex",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
