# Neovim Config

Zack's Neovim configuration. Nix-only — always loaded via nixCats. Never needs to run without Nix.

## How nixCats Works

[nixCats](https://github.com/BirdeeHub/nixCats-nvim) is a Nix-based Neovim package manager. It wraps Neovim with a Nix derivation and injects plugins/tools via the Nix store, exposing a global `nixCats('category.name')` Lua function for conditional logic.

**Flow:**
1. `flake.nix` declares plugin categories (`categoryDefinitions`) and which are enabled (`packageDefinitions`)
2. Nix builds the Neovim package, making plugins available as optional runtimepath entries
3. `init.lua` → `lua/myLuaConf/init.lua` loads everything
4. Plugins are lazy-loaded via **lze** using `for_cat = 'category'` to conditionally enable them

**Key concept:** `nixCats('general.extra')` returns `true`/`false` based on whether that category is enabled in `flake.nix`. All conditional plugin loading uses this.

## Structure

```
flake.nix                        # Plugin categories and package definitions
init.lua                         # Entry point → loads myLuaConf
lua/myLuaConf/
  init.lua                       # Loads all submodules
  opts_and_keys.lua              # Base options and keymaps (leader = <space>)
  debug.lua                      # DAP debugger setup
  lint.lua                       # nvim-lint setup
  format.lua                     # conform.nvim setup
  LSPs/
    init.lua                     # LSP specs loaded via lze lsp handler
    on_attach.lua                # LSP keymaps applied to all LSPs
  plugins/
    init.lua                     # Colorscheme, oil.nvim, plugin specs
    completion.lua               # blink.cmp
    telescope.lua                # Telescope fuzzy finder
    treesitter.lua               # Treesitter + text objects
```

## Adding Plugins

1. Add the plugin to the appropriate category in `flake.nix` under `startupPlugins` or `optionalPlugins`
2. Add a `lze` spec in the relevant Lua file using `for_cat = 'category.name'`
3. Run `nix build` or restart with the updated flake

## Adding LSPs

Add an lsp spec to `lua/myLuaConf/LSPs/init.lua` following the existing pattern. The lsp handler from lzextras handles `on_attach` and filetype detection automatically. Add runtime deps (the actual LSP binary) to `lspsAndRuntimeDeps` in `flake.nix`.

## Enabled Categories (packageDefinitions in flake.nix)

- `general` (always + extra + blink + treesitter + telescope + core)
- `markdown`
- `lint`
- `format`
- `neonixdev` (lua_ls, nixd, lazydev)
- Colorscheme: `kanagawa`

## Key Keymaps

- Leader: `<space>`
- `<leader>y/Y/p` — clipboard yank/paste
- `<leader><leader>[/]/l/d` — buffer navigation
- `<leader>s*` — telescope search
- `<leader>FF` — format file
- `<leader>b/B` — DAP breakpoints
- `F5/F1/F2/F3/F7` — DAP debug controls
- `gd/gr/gI/K` — LSP navigation
- `<leader>rn/<leader>ca` — LSP rename/code action
- `-` — oil.nvim file explorer
- `[c/]c` — git hunk navigation (gitsigns)
