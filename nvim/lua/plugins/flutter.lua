return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim",
  },
  config = function()
    local capabilities = pcall(require, "cmp_nvim_lsp")
      and require("cmp_nvim_lsp").default_capabilities()
      or vim.lsp.protocol.make_client_capabilities()

    local util = require("lspconfig.util")

    require("flutter-tools").setup({
      flutter_path = "/home/zaid/tools/flutter/bin/flutter",
      lsp = {
        capabilities = capabilities,
        root_dir = function(fname)
          local root = util.root_pattern(".git", "melos.yaml")(fname)
          
          if root then
            return root
          end

          return util.root_pattern("pubspec.yaml")(fname)
        end,

        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          enableSnippets = true,
          updateImportsOnRename = true,
          onlyAnalyzeProjectsWithOpenFiles = true,
        },
      },
      debugger = {
        enabled = true,
        run_on_start = false,
      },
    })
  end,
}