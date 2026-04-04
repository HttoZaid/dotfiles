return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]], 
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 3,
        width = function()
          return math.ceil(vim.o.columns * 0.8)
        end,
        height = function()
          return math.ceil(vim.o.lines * 0.8)
        end,
      },
    })

    function _G.set_terminal_keymaps()
      local opts = {buffer = 0}
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
      vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
      vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
      vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
    end

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end
}