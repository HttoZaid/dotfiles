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
          "/home/zaid/Projects/wordpress-core/wordpress/wp-includes",
          "/home/zaid/Projects/wordpress-core/wordpress/wp-admin/includes",
          "/home/zaid/Projects/wordpress-core/wordpress-tests-includes",
          "/home/zaid/Projects/wordpress-core/wordpress-tests-includes/factory",
        },
      },
    },
  },
})

vim.lsp.enable("intelephense")

local function php_root(filename)
  return vim.fs.root(filename, {
    "pint.json",
    ".php-cs-fixer.php",
    ".php-cs-fixer.dist.php",
    "composer.json",
    "agentic-wp.php",
    ".git",
  })
end

local function executable(path)
  return vim.fn.executable(path) == 1
end

local function readable(path)
  return vim.fn.filereadable(path) == 1
end

local function reload_buffer()
  vim.cmd("silent! edit")
end

local function run_pint(root, file)
  local local_pint = root .. "/vendor/bin/pint"
  local command = executable(local_pint) and local_pint or "pint"

  if not executable(command) then
    return false
  end

  local args = { command }

  if readable(root .. "/pint.json") then
    vim.list_extend(args, { "--config", root .. "/pint.json" })
  end

  table.insert(args, file)
  vim.fn.system(args)
  reload_buffer()

  return true
end

local function run_php_cs_fixer(root, file)
  local local_fixer = root .. "/vendor/bin/php-cs-fixer"
  local command = executable(local_fixer) and local_fixer or "php-cs-fixer"

  if not executable(command) then
    return false
  end

  local args = {
    command,
    "fix",
    file,
    "--using-cache=no",
  }

  if readable(root .. "/.php-cs-fixer.dist.php") then
    vim.list_extend(args, { "--config", root .. "/.php-cs-fixer.dist.php" })
  elseif readable(root .. "/.php-cs-fixer.php") then
    vim.list_extend(args, { "--config", root .. "/.php-cs-fixer.php" })
  end

  vim.fn.system(args)
  reload_buffer()

  return true
end

vim.api.nvim_create_autocmd("BufWritePost", {
  buffer = 0,
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    local root = php_root(file)

    if not root then
      return
    end

    if run_pint(root, file) then
      return
    end

    run_php_cs_fixer(root, file)
  end,
})
