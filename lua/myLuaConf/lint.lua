require('lze').load {
  {
    "nvim-lint",
    for_cat = 'lint',
    event = "FileType",
    after = function (plugin)
      require('lint').linters_by_ft = {
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
