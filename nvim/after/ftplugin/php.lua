vim.lsp.config("intelephense", {
  cmd = { "intelephense", "--stdio" },
  filetypes = { "php" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname, {
      "agentic-wp.php",
      "intelephense.config.json",
      "composer.json",
      ".git",
    })
    if root then
      on_dir(root)
    end
  end,
  settings = {
    intelephense = {
      telemetry = {
        enabled = false,
      },
      files = {
        maxSize = 5000000,
        associations = { "*.php", "*.phtml" },
      },
      environment = {
        includePaths = {
          "/home/zaid/Projects/wordpress-core/wordpress",
          "/home/zaid/Projects/wordpress-core/wordpress-tests-includes",
        },
      },
    },
  },
})
vim.lsp.enable("intelephense")
