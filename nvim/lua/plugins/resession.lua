return {
  "stevearc/resession.nvim",
  config = function()
    local resession = require("resession")
    resession.setup({
      autosave = {
        enabled = false,
      },
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          resession.load(vim.fn.getcwd(), { silence_errors = true })
        end
      end,
    })
  end,
}
