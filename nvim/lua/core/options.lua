local opt = vim.opt

-- Appearance
opt.relativenumber = true -- Relative line numbers for faster jumping
opt.number = true         -- Show absolute line number on current line
opt.termguicolors = true  -- True color support
opt.cursorline = true     -- Highlight the current line
opt.signcolumn = "yes"    -- Always show the sign column (prevents flickering)

-- Tabs & Indent
opt.tabstop = 2           -- 2 spaces for tabs
opt.shiftwidth = 2        -- 2 spaces for indent
opt.expandtab = true      -- Convert tabs to spaces
opt.autoindent = true     -- Copy indent from current line when starting new line

-- Behavior
opt.hidden = true -- Allow switching buffers without saving
opt.ignorecase = true     -- Ignore case in search patterns
opt.smartcase = true      -- Override ignorecase if search contains capitals
opt.mouse = "a"           -- Enable mouse support (don't judge, it's useful for resizing)
opt.splitright = true     -- Vertical splits open to the right
opt.splitbelow = true     -- Horizontal splits open below
opt.swapfile = false      -- Don't create swap files
opt.undofile = true       -- Save undo history to file (essential)
vim.opt.clipboard = "unnamedplus"

-- Performance
opt.updatetime = 250      -- Faster completion/triggering (default is 4000ms)

