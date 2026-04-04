return {
  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        window = { winblend = 0 },
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSPs
          "lua_ls",
          "ts_ls",
          "pyright",
          "clangd",
          "html",
          "cssls",
          "gopls",

          -- Formatters/Linters
          "stylua",
          "prettierd",
          "black",
          "isort",
          "clang-format",
          "goimports",


        },

        auto_update = true,
        run_on_start = true,
        start_delay = 3000,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsUpdateCompleted",
        callback = function()
        end,
      })
    end,
  },
}
