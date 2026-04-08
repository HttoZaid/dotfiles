return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "ibhagwan/fzf-lua",
    },
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "html",
          "cssls",
          "clangd",
          "gopls",
        },
        automatic_enable = false,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 4 },
        float = { border = "rounded", source = "always" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })

      vim.o.winborder = "rounded"

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "pyright",
        "html",
        "cssls",
        "clangd",
        "gopls",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          local fzf = require("fzf-lua")

          vim.keymap.set("n", "gd", function()
            fzf.lsp_definitions({ jump1 = true, ignore_current_line = true })
          end, opts)

          vim.keymap.set("n", "gi", function()
            fzf.lsp_implementations({ jump1 = true })
          end, opts)

          vim.keymap.set("n", "gr", function()
            fzf.lsp_references({ ignore_current_line = true })
          end, opts)

          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", fzf.lsp_code_actions, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },
}
