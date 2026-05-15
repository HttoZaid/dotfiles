local keymap = vim.keymap

-- =============================================================================
--  CORE OPERATIONS
-- =============================================================================

-- Exit Insert Mode (The "jk" escape)
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Quick Save/Quit
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Quick save" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quick quit" })

-- Search & Highlighting
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Make 'n' and 'N' center the screen and trigger hlslens virtual text
local hlslens_status, hlslens = pcall(require, 'hlslens')
if hlslens_status then
    local kopts = { noremap = true, silent = true }

    keymap.set('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zz]],
        kopts)
    keymap.set('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zz]],
        kopts)
    keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
end

-- =============================================================================
--  NAVIGATION (Windows & Buffers)
-- =============================================================================

-- Window Navigation (Ctrl + hjkl)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Bufferline Navigation
keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Buffer Pick (Jump to)" })

-- Smart Buffer Close (Closes buffer but keeps the window split)
keymap.set("n", "<leader>x", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })

    if #listed_buffers <= 1 then
        vim.cmd("enew")
        vim.cmd("bd #")
    else
        vim.cmd("bp")
        vim.cmd("bd " .. bufnr)
    end
end, { desc = "Close current buffer" })

-- =============================================================================
--  TEXT EDITING & VISUAL MODE
-- =============================================================================

-- Indenting (Stay in visual mode after shifting)
keymap.set("v", "<", "<gv", { desc = "Indent left" })
keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move Selection (Alt-style block movement)
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Insert Mode Navigation (Home/End and Arrows)
keymap.set("i", "<C-h>", "<Left>", { desc = "Cursor left" })
keymap.set("i", "<C-j>", "<Down>", { desc = "Cursor down" })
keymap.set("i", "<C-k>", "<Up>", { desc = "Cursor up" })
keymap.set("i", "<C-l>", "<Right>", { desc = "Cursor right" })
keymap.set("i", "<C-a>", "<ESC>I", { desc = "Move to start of line" })
keymap.set("i", "<C-e>", "<ESC>A", { desc = "Move to end of line" })

-- =============================================================================
--  FUZZY FINDER (fzf-lua)
-- =============================================================================

local fzf_wrapper = function(cmd, opts)
    return function()
        local defaults = {
            jump_to_column = true,
            winopts = {
                preview = { layout = "vertical" },
            },
        }
        local final_opts = vim.tbl_deep_extend("force", defaults, opts or {})
        require("fzf-lua")[cmd](final_opts)
    end
end

-- --- Search & Discovery ---
keymap.set("n", "<leader>ff", fzf_wrapper("files"), { desc = "Fzf: Find Project Files" })
keymap.set("n", "<leader>fb", fzf_wrapper("buffers"), { desc = "Fzf: Open Buffers" })
keymap.set("n", "<leader>fh", fzf_wrapper("help_tags"), { desc = "Fzf: Documentation Tags" })

-- --- The Grep Engine (Project-Wide) ---
-- Live Grep: Fuzzy search as you type
keymap.set("n", "<leader>fg", fzf_wrapper("live_grep"), { desc = "Fzf: Live Grep (Global)" })
-- Grep Word: Find the exact string under your cursor across the project
keymap.set("n", "<leader>fs", fzf_wrapper("grep_cword"), { desc = "Fzf: Search Word under Cursor" })
-- Project Search: Manual entry for an exact string search
keymap.set("n", "<leader>sp", fzf_wrapper("grep"), { desc = "Fzf: Manual Project Search" })

-- --- The "Modern /" (In-File Search) ---
-- Persistent Search: Like '/' but the list stays open while you browse
keymap.set("n", "<leader>f/", fzf_wrapper("grep_curbuf"), { desc = "Fzf: Search in Current Buffer" })

-- =============================================================================
--  FILE EXPLORERS (NvimTree & Oil)
-- =============================================================================

-- Sidebar Tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })

-- Oil.nvim (The "Vinegar" style explorer)
keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
keymap.set("n", "<leader>of", "<CMD>Oil --float<CR>", { desc = "Open Oil in float" })

-- =============================================================================
--  LSP & DIAGNOSTICS
-- =============================================================================

keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Floating diagnostic" })
keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Noice History & Scrolling (LSP Hover Docs)
keymap.set("n", "<leader>nl", "<cmd>Noice last<cr>", { desc = "Noice: Last message" })
keymap.set("n", "<leader>nh", "<cmd>Noice history<cr>", { desc = "Noice: History" })
keymap.set("n", "<leader>nd", "<cmd>Noice dismiss<cr>", { desc = "Noice: Dismiss all" })

keymap.set({ "n", "i", "s" }, "<c-f>", function()
    if not require("noice.lsp").scroll(4) then return "<c-f>" end
end, { silent = true, expr = true, desc = "Scroll Hover Forward" })

keymap.set({ "n", "i", "s" }, "<c-b>", function()
    if not require("noice.lsp").scroll(-4) then return "<c-b>" end
end, { silent = true, expr = true, desc = "Scroll Hover Backward" })

-- =============================================================================
--  TERMINAL (ToggleTerm)
-- =============================================================================

keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })
keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", { desc = "Terminal: Vertical" })

-- =============================================================================
--  GIT & SESSIONS
-- =============================================================================

-- Diffview
keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Git: Open Diff" })
keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<CR>", { desc = "Git: Close Diff" })

-- Resession (Session Management)
-- Save the current session
keymap.set("n", "<leader>ss", function()
    require("resession").save(vim.fn.getcwd(), { dir = "dirsession" })
end, { desc = "Session: Save current" })

-- Load a session
keymap.set("n", "<leader>sl", function()
    vim.cmd("silent! wa")
    require("resession").load(nil, { dir = "dirsession" })
end, { desc = "Session: Load/Select" })

-- Delete a session
keymap.set("n", "<leader>sd", function()
    require("resession").delete(nil, { dir = "dirsession" })
end, { desc = "Session: Delete" })
