require('lze').load {
  {
    "conform.nvim",
    for_cat = 'format',
    keys = {
      { "<leader>FF", desc = "[F]ormat [F]ile" },
    },
    after = function (plugin)
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>FF", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[F]ormat [F]ile" })
    end,
  },
}
