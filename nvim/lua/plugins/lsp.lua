---@diagnostic disable: missing-fields
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = { virtual_text = { prefix = "icons" } },
      servers = {
        ["*"] = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = false,
              },
            },
          },
        },
        qmlls = {
          cmd = { "qmlls6" },
          root_markers = { ".qmlls.ini" },
        },
        jsonls = {
          filetypes = { "json", "jsonc", "json5" },
        },
        phpactor = { enabled = false },
        lua_ls = {
          settings = {
            Lua = {
              misc = {},
              hover = { expandAlias = false },
              type = {
                castNumberToInteger = true,
                inferParamType = true,
              },
              diagnostics = {
                disable = {
                  "incomplete-signature-doc",
                  "trailing-space",
                  "missing-local-export-doc",
                },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ambiguity = "Opened",
                  await = "Opened",
                  codestyle = "None",
                  duplicate = "Opened",
                  global = "Opened",
                  luadoc = "Opened",
                  redefined = "Opened",
                  strict = "Opened",
                  strong = "Opened",
                  ["type-check"] = "Opened",
                  unbalanced = "Opened",
                  unused = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
            },
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "pint", "php_cs_fixer", stop_after_first = true },
      },
      formatters = {
        dprint = {
          condition = function(_, ctx)
            return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          end,
        },
        pint = {
          condition = function(_, ctx)
            return vim.fs.find({ "pint.json" }, { path = ctx.filename, upward = true })[1]
          end,
        },
        php_cs_fixer = {
          condition = function(_, ctx)
            return vim.fs.find(
              { ".php-cs-fixer.php", ".php-cs-fixer.dist.php" },
              { path = ctx.filename, upward = true }
            )[1]
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        lua = { "luacheck" },
      },
      linters = {
        selene = {
          condition = function()
            local root = LazyVim.root.get({ normalize = true })
            if root ~= vim.uv.cwd() then
              return false
            end
            return vim.fs.find({ "selene.toml" }, { path = root, upward = true })[1]
          end,
        },
        luacheck = {
          condition = function()
            local root = LazyVim.root.get({ normalize = true })
            if root ~= vim.uv.cwd() then
              return false
            end
            return vim.fs.find({ ".luacheckrc" }, { path = root, upward = true })[1]
          end,
        },
      },
    },
  },
}
