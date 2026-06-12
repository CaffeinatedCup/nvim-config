require('lze').load {
  {
    "nvim-lint",
    for_cat = 'lint',
    event = "FileType",
    after = function (plugin)
      require('lint').linters_by_ft = {
        python   = { "ruff" },         -- complements pyright (unused imports, bugbear, style)
        markdown = { "markdownlint" }, -- no LSP for markdown
        nix      = { "statix" },       -- idiom/anti-pattern lints nixd doesn't catch
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
