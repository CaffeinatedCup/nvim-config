-- setting colorscheme
local colorschemeName = nixCats('colorscheme')
vim.cmd.colorscheme(colorschemeName)

local ok, notify = pcall(require, "notify")
if ok then
  notify.setup({
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  })
  vim.notify = notify
  vim.keymap.set("n", "<Esc>", function()
      notify.dismiss({ silent = true, })
  end, { desc = "dismiss notify popup and clear hlsearch" })
end

if nixCats('general.extra') then
  vim.g.loaded_netrwPlugin = 1
  require("oil").setup({
    default_file_explorer = true,
    view_options = {
      show_hidden = true
    },
    columns = {
      "icon",
      "permissions",
      "size",
      -- "mtime",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
  })
  vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = 'Open Parent Directory' })
  vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = 'Open nvim root directory' })

  local harpoon = require("harpoon")
  harpoon:setup()
  vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,                              { desc = "Harpoon add file" })
  vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,      { desc = "Harpoon menu" })
  vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,                          { desc = "Harpoon file 1" })
  vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,                          { desc = "Harpoon file 2" })
  vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,                          { desc = "Harpoon file 3" })
  vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,                          { desc = "Harpoon file 4" })
  vim.keymap.set("n", "<leader>h[", function() harpoon:list():prev() end,                             { desc = "Harpoon prev" })
  vim.keymap.set("n", "<leader>h]", function() harpoon:list():next() end,                             { desc = "Harpoon next" })

  local alpha = require('alpha')
  local dashboard = require('alpha.themes.dashboard')
  dashboard.section.header.val = {
    " /$$    /$$ /$$$$$$ /$$      /$$ /$$$$$$$   /$$$$$$  /$$$$$$$  /$$$$$$$$",
    "| $$   | $$|_  $$_/| $$$    /$$$| $$__  $$ /$$__  $$| $$__  $$| $$_____/",
    "| $$   | $$  | $$  | $$$$  /$$$$| $$  \\ $$| $$  \\ $$| $$  \\ $$| $$      ",
    "|  $$ / $$/  | $$  | $$ $$/$$ $$| $$$$$$$/| $$  | $$| $$$$$$$/| $$$$$   ",
    " \\  $$ $$/   | $$  | $$  $$$| $$| $$____/ | $$  | $$| $$__  $$| $$__/   ",
    "  \\  $$$/    | $$  | $$\\  $ | $$| $$      | $$  | $$| $$  \\ $$| $$      ",
    "   \\  $/    /$$$$$$| $$ \\/  | $$| $$      |  $$$$$$/| $$  | $$| $$$$$$$$",
    "    \\_/    |______/|__/     |__/|__/       \\______/ |__/  |__/|________/",
  }
  dashboard.section.buttons.val = {
    dashboard.button("f", "  Find File",    "<cmd>Telescope find_files<CR>"),
    dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<CR>"),
    dashboard.button("g", "  Live Grep",    "<cmd>Telescope live_grep<CR>"),
    dashboard.button("e", "  New File",     "<cmd>enew<CR>"),
    dashboard.button("q", "  Quit",         "<cmd>qa<CR>"),
  }
  alpha.setup(dashboard.config)
end

require('lze').load {
  { import = "myLuaConf.plugins.telescope", },
  { import = "myLuaConf.plugins.treesitter", },
  { import = "myLuaConf.plugins.completion", },
  { import = "myLuaConf.plugins.latex", },
  { import = "myLuaConf.plugins.claudecode", },
  {
    "markdown-preview.nvim",
    for_cat = 'general.markdown',
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "obsidian.nvim",
    for_cat = 'obsidian',
    ft = "markdown",
    cmd = { "ObsidianBacklinks", "ObsidianDailies", "ObsidianExtractNote",
      "ObsidianFollowLink", "ObsidianLink", "ObsidianLinkNew", "ObsidianLinks",
      "ObsidianNew", "ObsidianNewFromTemplate", "ObsidianOpen", "ObsidianPasteImg",
      "ObsidianQuickSwitch", "ObsidianRename", "ObsidianSearch", "ObsidianTags",
      "ObsidianTemplate", "ObsidianToday", "ObsidianToggleCheckbox",
      "ObsidianTomorrow", "ObsidianTOC", "ObsidianYesterday" },
    keys = {
      { "<leader>ob", "<cmd>ObsidianBacklinks<CR>",   mode = { "n" }, desc = "Obsidian backlinks" },
      { "<leader>od", "<cmd>ObsidianToday<CR>",       mode = { "n" }, desc = "Obsidian daily note" },
      { "<leader>ol", "<cmd>ObsidianLinks<CR>",       mode = { "n" }, desc = "Obsidian note links" },
      { "<leader>oo", "<cmd>ObsidianOpen<CR>",        mode = { "n" }, desc = "Open in Obsidian" },
      { "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", mode = { "n" }, desc = "Find note in vault" },
      { "<leader>ot", "<cmd>ObsidianTemplate<CR>",    mode = { "n" }, desc = "Insert Obsidian template" },
      { "<leader>oT", "<cmd>ObsidianTOC<CR>",         mode = { "n" }, desc = "Obsidian table of contents" },
    },
    before = function(_)
      local group = vim.api.nvim_create_augroup("obsidian-markdown", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group, pattern = "markdown",
        callback = function(args)
          require("myLuaConf.plugins.obsidian").setup_markdown_buffer(args.buf)
        end,
      })
    end,
    after = function(_)
      -- obsidian's blink completion (register_providers/inject_sources) requires
      -- blink.cmp to already be loaded + configured. blink normally loads on
      -- DeferredUIEnter, which can race when opening nvim directly on a markdown
      -- file, so force it to load now before wiring obsidian's sources.
      pcall(require('lze').trigger_load, "blink.cmp")
      local oh = require("myLuaConf.plugins.obsidian")
      require("obsidian").setup(oh.opts())
    end,
  },
  {
    "render-markdown.nvim",
    for_cat = 'obsidian',
    ft = "markdown",
    after = function(_)
      require("render-markdown").setup({})
    end,
  },
  {
    "undotree",
    for_cat = 'general.extra',
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "comment.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('Comment').setup()
    end,
  },
  {
    "indent-blankline.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require("ibl").setup()
    end,
  },
  {
    "nvim-surround",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    "vim-startuptime",
    for_cat = 'general.extra',
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "fidget.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('fidget').setup({})
    end,
  },
  {
    "lualine.nvim",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    after = function (plugin)
      require('lualine').setup({
        options = {
          icons_enabled = false,
          theme = colorschemeName,
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename', path = 1, status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename', path = 3, status = true,
            },
          },
          lualine_x = {'filetype'},
        },
        tabline = {
          lualine_a = { 'buffers' },
          lualine_z = { 'tabs' }
        },
      })
    end,
  },
  {
    "gitsigns.nvim",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    after = function (plugin)
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end,
  },
  {
    "which-key.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function (plugin)
      require('which-key').setup({
      })
      require('which-key').add {
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]ebug" },
        { "<leader>d_", hidden = true },
        { "<leader>a", group = "[a]i" },
        { "<leader>a_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>h", group = "[h]arpoon" },
        { "<leader>h_", hidden = true },
        { "<leader>l", group = "[l]atex" },
        { "<leader>l_", hidden = true },
        { "<leader>m", group = "[m]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>o", group = "[o]bsidian" },
        { "<leader>o_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
      }
    end,
  },
}
