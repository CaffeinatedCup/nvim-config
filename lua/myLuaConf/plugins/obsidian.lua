-- obsidian.nvim configuration and helpers.
--
-- This module builds the options table passed to `require("obsidian").setup`
-- (see `opts` below) plus a handful of supporting helpers: vault discovery,
-- note-id generation, and markdown buffer tweaks. obsidian.nvim renders the
-- `{{date:...}}` / `{{time:...}}` template tokens natively, so nothing here
-- needs to patch that in.
--
-- The vault on disk uses capitalized top-level folders (Notes/, Templates/,
-- Education/, Projects/), so every path this module reads from or writes to
-- must match that casing. Those folder names are centralized below.

-- Vault folder layout. Keep these capitalized to match the real directories in
-- the vault, otherwise obsidian.nvim creates parallel lowercase folders.
local NOTES_DIR = "Notes"
local DAILIES_DIR = "Notes/dailies"
local TEMPLATES_DIR = "Templates"
local ATTACHMENTS_DIR = "assets/imgs"

-- =========================================================================
-- Small filesystem / env helpers
-- =========================================================================

-- Expand `~`, environment variables, etc. in a path string.
local function expand(path)
  return vim.fn.expand(path)
end

-- Read environment variable `name`; fall back to `fallback` when it is unset or
-- empty. Either way the result is path-expanded.
local function env_or(name, fallback)
  local value = vim.env[name]

  if value ~= nil and value ~= "" then
    return expand(value)
  end

  return expand(fallback)
end

local function is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

-- =========================================================================
-- Workspace (vault) discovery
-- =========================================================================

-- Validate and clean up a single `{ name, path }` workspace entry. Returns a
-- normalized copy, or nil if the entry is malformed or its directory is missing.
local function normalize_workspace(workspace)
  if type(workspace) ~= "table" or type(workspace.path) ~= "string" then
    return nil
  end

  local normalized = vim.deepcopy(workspace)
  normalized.path = expand(normalized.path)

  if not is_dir(normalized.path) then
    return nil
  end

  -- Derive a name from the folder when one wasn't supplied.
  if type(normalized.name) ~= "string" or normalized.name == "" then
    normalized.name = vim.fs.basename(normalized.path)
  end

  return normalized
end

-- Walk upward from the current buffer / cwd looking for a `.obsidian` directory,
-- which marks the root of an Obsidian vault. Returns the vault root path or nil.
local function detect_vault_root()
  local candidates = {
    vim.api.nvim_buf_get_name(0),
    vim.uv.cwd(),
  }

  for _, candidate in ipairs(candidates) do
    if type(candidate) == "string" and candidate ~= "" then
      local start = candidate

      -- Search from the containing directory when we started at a file.
      if vim.fn.filereadable(start) == 1 then
        start = vim.fs.dirname(start)
      end

      local root = vim.fs.find(".obsidian", {
        path = start,
        upward = true,
        type = "directory",
        limit = 1,
      })[1]

      if root then
        return vim.fs.dirname(root)
      end
    end
  end

  return nil
end

-- Build the list of vault workspaces obsidian.nvim should know about.
--
-- Priority order:
--   1. `vim.g.obsidian_workspaces` if the user set it explicitly.
--   2. The OBSIDIAN_VAULT_PERSONAL env var (default ~/vault), plus any vault
--      auto-detected from the current buffer/cwd.
--   3. A hard ~/vault fallback so setup never runs with zero workspaces.
local function collect_workspaces()
  -- 1. Explicit override via global.
  if type(vim.g.obsidian_workspaces) == "table" and #vim.g.obsidian_workspaces > 0 then
    local workspaces = {}

    for _, workspace in ipairs(vim.g.obsidian_workspaces) do
      local normalized = normalize_workspace(workspace)

      if normalized then
        workspaces[#workspaces + 1] = normalized
      end
    end

    if #workspaces > 0 then
      return workspaces
    end
  end

  -- 2. Default personal vault (from env or ~/vault), de-duplicated by path.
  local configured = {
    {
      name = "personal",
      path = env_or("OBSIDIAN_VAULT_PERSONAL", "~/vault"),
    },
  }

  local existing = {}
  local seen = {}

  for _, workspace in ipairs(configured) do
    local normalized = normalize_workspace(workspace)

    if normalized and not seen[normalized.path] then
      seen[normalized.path] = true
      existing[#existing + 1] = normalized
    end
  end

  -- Add the vault we're currently inside, if any and not already listed.
  local detected_root = detect_vault_root()

  if detected_root and not seen[detected_root] then
    existing[#existing + 1] = {
      name = vim.fs.basename(detected_root),
      path = detected_root,
    }
  end

  -- 3. Guarantee at least one workspace so obsidian.nvim setup never errors when
  -- nothing is detected. Fall back to the real vault rather than cwd, so a
  -- misconfigured launch never dumps notes into whatever dir nvim started in.
  if #existing == 0 then
    existing[#existing + 1] = {
      name = "personal",
      path = expand("~/vault"),
    }
  end

  return existing
end

-- =========================================================================
-- Note IDs
-- =========================================================================

-- Turn a free-form title into a URL/filename-friendly slug:
-- lowercase, strip punctuation, collapse whitespace and dashes to single "-".
local function slugify(text)
  local slug = text:lower()
  slug = slug:gsub("[^a-z0-9%s-]", "") -- drop anything but letters/digits/space/dash
  slug = slug:gsub("%s+", "-") -- spaces -> dashes
  slug = slug:gsub("%-+", "-") -- collapse repeated dashes
  slug = slug:gsub("^%-", "") -- trim leading dash
  slug = slug:gsub("%-$", "") -- trim trailing dash

  return slug
end

-- =========================================================================
-- Misc helpers
-- =========================================================================

-- Open a URL or image path with the OS default handler.
local function open_with_system(path)
  if vim.ui.open then
    vim.ui.open(path)
    return
  end

  vim.fn.jobstart({ "xdg-open", path }, { detach = true })
end

-- Locate the daily-note template (Templates/daily.md) within any workspace.
-- Returns the template's basename for obsidian.nvim, or nil if none exists.
local function find_daily_template(workspaces)
  for _, workspace in ipairs(workspaces) do
    if type(workspace.path) == "string" then
      local template = vim.fs.joinpath(expand(workspace.path), TEMPLATES_DIR, "daily.md")

      if vim.fn.filereadable(template) == 1 then
        return "daily.md"
      end
    end
  end

  return nil
end

-- Apply prose-friendly local options whenever a markdown/obsidian buffer opens
-- (soft wrap, conceal markup, no spell, 100-col text width, list-aware reflow).
local function setup_markdown_buffer(bufnr)
  local opt = vim.opt_local

  opt.wrap = true
  opt.linebreak = true
  opt.conceallevel = 2
  opt.concealcursor = "nc"
  opt.spell = false
  opt.textwidth = 100

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.formatoptions:append({ "n", "2" }) -- recognize numbered lists, indent by 2nd line
    vim.opt_local.formatoptions:remove("t") -- don't auto-wrap plain text while typing
  end)
end

-- =========================================================================
-- Main options table
-- =========================================================================

local function opts()
  local workspaces = collect_workspaces()

  return {
    workspaces = workspaces,

    -- New notes land in Notes/ using wiki-style [[links]], most-recently
    -- modified first, opened in the current window.
    notes_subdir = NOTES_DIR,
    new_notes_location = "notes_subdir",
    preferred_link_style = "wiki",
    sort_by = "modified",
    sort_reversed = true,
    open_notes_in = "current",

    -- Completion is driven by blink.cmp (nvim-cmp disabled).
    completion = {
      nvim_cmp = false,
      blink = true,
      min_chars = 2,
    },

    daily_notes = {
      folder = DAILIES_DIR,
      date_format = "%Y-%m-%d",
      alias_format = "%A, %B %-d, %Y",
      default_tags = { "daily", "journal" },
      template = find_daily_template(workspaces),
    },

    templates = {
      folder = TEMPLATES_DIR,
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- Extra `{{weekday}}` / `{{cursor}}` template substitutions on top of the
      -- `{{date:...}}` / `{{time:...}}` tokens obsidian.nvim handles natively.
      substitutions = {
        weekday = function()
          return os.date("%A")
        end,
        cursor = function()
          return "<++>"
        end,
      },
    },

    -- Filename/id for new notes: "YYYYMMDD-HHMM-<slugified-title>", falling back
    -- to a unix timestamp when there's no title to slugify.
    note_id_func = function(title)
      local suffix = title and slugify(title) or ""

      if suffix == "" then
        suffix = tostring(os.time())
      end

      return string.format("%s-%s", os.date("%Y%m%d-%H%M"), suffix)
    end,

    -- Frontmatter written to each note: id/aliases/tags, plus any custom
    -- metadata already present on the note.
    note_frontmatter_func = function(note)
      if note.title then
        note:add_alias(note.title)
      end

      local out = {
        id = note.id,
        aliases = note.aliases,
        tags = note.tags,
      }

      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for key, value in pairs(note.metadata) do
          out[key] = value
        end
      end

      return out
    end,

    -- Buffer-local mappings active inside notes.
    mappings = {
      -- Follow links under the cursor with `gf`.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- <CR> follows links / toggles checkboxes depending on context.
      ["<CR>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
      ["<leader>oc"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true, desc = "Toggle checkbox" },
      },
    },

    -- Telescope-backed picker, with link/tag insertion shortcuts.
    picker = {
      name = "telescope.nvim",
      note_mappings = {
        new = "<C-x>",
        insert_link = "<C-l>",
      },
      tag_mappings = {
        tag_note = "<C-x>",
        insert_tag = "<C-l>",
      },
    },

    -- Pasted images go to assets/imgs with a timestamped name.
    attachments = {
      img_folder = ATTACHMENTS_DIR,
      img_name_func = function()
        return string.format("%s-", os.date("%Y%m%d-%H%M%S"))
      end,
    },

    -- Open links/images with the OS handler instead of inside nvim.
    follow_url_func = open_with_system,
    follow_img_func = open_with_system,

    -- Disable obsidian.nvim's own UI; render-markdown.nvim handles rendering.
    ui = {
      enable = false,
    },

    callbacks = {
      enter_note = function()
        setup_markdown_buffer(0)
      end,
    },
  }
end

return {
  opts = opts,
  setup_markdown_buffer = setup_markdown_buffer,
}
