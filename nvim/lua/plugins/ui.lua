return {
  { "akinsho/bufferline.nvim", opts = { options = { separator_style = "slope" } } },

  {
    "folke/which-key.nvim",
    enabled = true,
    opts = {
      preset = "helix",
      debug = vim.uv.cwd():find("which%-key"),
      win = {},
      spec = {},
    },
  },

  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.debug = vim.uv.cwd():find("noice%.nvim")
      opts.debug = false
      opts.routes = opts.routes or {}
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })

      table.insert(opts.routes, 1, {
        filter = {
          ["not"] = {
            event = "lsp",
            kind = "progress",
          },
          cond = function()
            return not focused and false
          end,
        },
        view = "notify_send",
        opts = { stop = false, replace = true },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })
      return opts
    end,
  },

  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      ---@type table<string, {updated:number, total:number, enabled: boolean, status:string[]}>
      local mutagen = {}

      local function mutagen_status()
        local cwd = vim.uv.cwd() or "."
        mutagen[cwd] = mutagen[cwd]
          or {
            updated = 0,
            total = 0,
            enabled = vim.fs.find("mutagen.yml", { path = cwd, upward = true })[1] ~= nil,
            status = {},
          }
        local now = vim.uv.now() -- timestamp in milliseconds
        local refresh = mutagen[cwd].updated + 10000 < now
        if #mutagen[cwd].status > 0 then
          refresh = mutagen[cwd].updated + 1000 < now
        end
        if mutagen[cwd].enabled and refresh then
          ---@type {name:string, status:string, idle:boolean}[]
          local sessions = {}
          local lines = vim.fn.systemlist("mutagen project list")
          local status = {}
          local name = nil
          for _, line in ipairs(lines) do
            local n = line:match("^Name: (.*)")
            if n then
              name = n
            end
            local s = line:match("^Status: (.*)")
            if s then
              table.insert(sessions, {
                name = name,
                status = s,
                idle = s == "Watching for changes",
              })
            end
          end
          for _, session in ipairs(sessions) do
            if not session.idle then
              table.insert(status, session.name .. ": " .. session.status)
            end
          end
          mutagen[cwd].updated = now
          mutagen[cwd].total = #sessions
          mutagen[cwd].status = status
          if #sessions == 0 then
            vim.notify("Mutagen is not running", vim.log.levels.ERROR, { title = "Mutagen" })
          end
        end
        return mutagen[cwd]
      end

      local error_color = { fg = Snacks.util.color("DiagnosticError") }
      local ok_color = { fg = Snacks.util.color("DiagnosticInfo") }
      table.insert(opts.sections.lualine_x, {
        cond = function()
          return mutagen_status().enabled
        end,
        color = function()
          return (mutagen_status().total == 0 or mutagen_status().status[1]) and error_color or ok_color
        end,
        function()
          local s = mutagen_status()
          local msg = s.total
          if #s.status > 0 then
            msg = msg .. " | " .. table.concat(s.status, " | ")
          end
          return (s.total == 0 and "󰋘 " or "󰋙 ") .. msg
        end,
      })
    end,
  },

  -- "folke/twilight.nvim",

  -- {
  --   "folke/zen-mode.nvim",
  --   cmd = "ZenMode",
  --   opts = {
  --     window = { backdrop = 0.7 },
  --     plugins = {
  --       gitsigns = true,
  --       tmux = true,
  --       kitty = { enabled = false, font = "+2" },
  --     },
  --   },
  --   keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  -- },
  --
  -- return {
    { "akinsho/bufferline.nvim", opts = { options = { separator_style = "slope" } } },

    {
      "folke/which-key.nvim",
      enabled = true,
      opts = {
        preset = "helix",
        debug = vim.uv.cwd():find("which%-key"),
        win = {},
        spec = {},
      },
    },

    {
      "folke/noice.nvim",
      opts = function(_, opts)
        opts.debug = vim.uv.cwd():find("noice%.nvim")
        opts.debug = false
        opts.routes = opts.routes or {}
        table.insert(opts.routes, {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        })
        local focused = true
        vim.api.nvim_create_autocmd("FocusGained", {
          callback = function()
            focused = true
          end,
        })
        vim.api.nvim_create_autocmd("FocusLost", {
          callback = function()
            focused = false
          end,
        })

        table.insert(opts.routes, 1, {
          filter = {
            ["not"] = {
              event = "lsp",
              kind = "progress",
            },
            cond = function()
              return not focused and false
            end,
          },
          view = "notify_send",
          opts = { stop = false, replace = true },
        })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function(event)
            vim.schedule(function()
              require("noice.text.markdown").keys(event.buf)
            end)
          end,
        })
        return opts
      end,
    },

    -- lualine
    {
      "nvim-lualine/lualine.nvim",
      opts = function(_, opts)
        ---@type table<string, {updated:number, total:number, enabled: boolean, status:string[]}>
        local mutagen = {}

        local function mutagen_status()
          local cwd = vim.uv.cwd() or "."
          mutagen[cwd] = mutagen[cwd]
            or {
              updated = 0,
              total = 0,
              enabled = vim.fs.find("mutagen.yml", { path = cwd, upward = true })[1] ~= nil,
              status = {},
            }
          local now = vim.uv.now() -- timestamp in milliseconds
          local refresh = mutagen[cwd].updated + 10000 < now
          if #mutagen[cwd].status > 0 then
            refresh = mutagen[cwd].updated + 1000 < now
          end
          if mutagen[cwd].enabled and refresh then
            ---@type {name:string, status:string, idle:boolean}[]
            local sessions = {}
            local lines = vim.fn.systemlist("mutagen project list")
            local status = {}
            local name = nil
            for _, line in ipairs(lines) do
              local n = line:match("^Name: (.*)")
              if n then
                name = n
              end
              local s = line:match("^Status: (.*)")
              if s then
                table.insert(sessions, {
                  name = name,
                  status = s,
                  idle = s == "Watching for changes",
                })
              end
            end
            for _, session in ipairs(sessions) do
              if not session.idle then
                table.insert(status, session.name .. ": " .. session.status)
              end
            end
            mutagen[cwd].updated = now
            mutagen[cwd].total = #sessions
            mutagen[cwd].status = status
            if #sessions == 0 then
              vim.notify("Mutagen is not running", vim.log.levels.ERROR, { title = "Mutagen" })
            end
          end
          return mutagen[cwd]
        end

        local error_color = { fg = Snacks.util.color("DiagnosticError") }
        local ok_color = { fg = Snacks.util.color("DiagnosticInfo") }
        table.insert(opts.sections.lualine_x, {
          cond = function()
            return mutagen_status().enabled
          end,
          color = function()
            return (mutagen_status().total == 0 or mutagen_status().status[1]) and error_color or ok_color
          end,
          function()
            local s = mutagen_status()
            local msg = s.total
            if #s.status > 0 then
              msg = msg .. " | " .. table.concat(s.status, " | ")
            end
            return (s.total == 0 and "󰋘 " or "󰋙 ") .. msg
          end,
        })
      end,
    },

    -- "folke/twilight.nvim",

    -- {
    --   "folke/zen-mode.nvim",
    --   cmd = "ZenMode",
    --   opts = {
    --     window = { backdrop = 0.7 },
    --     plugins = {
    --       gitsigns = true,
    --       tmux = true,
    --       kitty = { enabled = false, font = "+2" },
    --     },
    --   },
    --   keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    -- },
    {
      "rose-pine/neovim",
      name = "rose-pine",
      lazy = false,
      priority = 1000,
      config = function()
        require("rose-pine").setup({
          variant = "moon",
          dark_variant = "moon",

          styles = {
            bold = true,
            italic = false,
            transparency = false,
          },

          highlight_groups = {
            Normal = { bg = "#1e1e2e", fg = "#e0e0e0" },
            CursorLine = { bg = "#2a2a3c" },
            StatusLine = { bg = "#2a2a3c", fg = "#e0e0e0" },

            -- Structural Overrides
            Comment = { fg = "#6272a4", italic = false },
            Keyword = { fg = "#81a1c1", bold = true },
            Statement = { fg = "#81a1c1", bold = true },
            Function = { fg = "#88c0d0", bold = true },
            String = { fg = "#a3be8c" },
            Number = { fg = "#d8dee9" },
            Boolean = { fg = "#d8dee9", bold = true },

            -- Navigation Indicators
            LineNr = { fg = "#4c566a" },
            CursorLineNr = { fg = "#88c0d0", bold = true },
            Visual = { bg = "#3b4252" },
          },
        })

        vim.opt.background = "dark"
        vim.cmd("colorscheme rose-pine-moon")
      end,
    },
}
