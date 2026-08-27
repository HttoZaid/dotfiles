--- Block arrow keys in normal and visual mode.
vim.keymap.set({ "n", "v" }, "<Up>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<Down>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<Left>", "<Nop>", { silent = true })
vim.keymap.set({ "n", "v" }, "<Right>", "<Nop>", { silent = true })
