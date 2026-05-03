return {
  {
    "claudecode-nvim",
    for_cat = 'claudecode',
    event = "DeferredUIEnter",
    after = function(_)
      require("claudecode").setup({
        terminal = {
          provider = "native",
          split_side = "right",
          split_width_percentage = 0.35,
          auto_close = true,
        },
      })
      vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<CR>",           { desc = "Toggle Claude Code" })
      vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<CR>",      { desc = "Focus Claude Code" })
      vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<CR>",       { desc = "Send selection to Claude" })
      vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", { desc = "Accept diff" })
      vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>",   { desc = "Deny diff" })
    end,
  },
}
