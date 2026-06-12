# nvim-config

Zack's personal Neovim configuration, built with
[nixCats](https://github.com/BirdeeHub/nixCats-nvim). Plugins, LSPs, linters,
and formatters are all declared in `flake.nix` and pulled from the Nix store, so
the whole editor is reproducible from a single `nix build` — no `:PackerSync`,
no `mason`, no global tool installs. The Lua side lives under `lua/myLuaConf/`
and lazy-loads plugins with [lze](https://github.com/BirdeeHub/lze), gating each
one on a nixCats category.

Languages wired up with LSP + formatting/linting: **Lua, Nix, Python, Rust,
C/C++, LaTeX, Markdown**. See `CLAUDE.md` for an architecture overview and
`flake.nix` for the enabled categories.

## Keybindings

Leader is `<Space>`. Many mappings are buffer- or filetype-local (LSP, Obsidian,
LaTeX) and only apply where relevant.

### Editing & movement
| Key | Mode | Action |
| --- | --- | --- |
| `<Esc>` | n | Clear search highlight |
| `J` / `K` | v | Move selection down / up |
| `<C-d>` / `<C-u>` | n | Half-page scroll, centered |
| `n` / `N` | n | Next / previous search result, centered |
| `j` / `k` | n | Wrap-aware down / up |
| `<C-a>` | n/v | Select all |
| `<leader>r` | n | Run current file (python/rust/c/lua) |
| `<Esc>` | t | Exit terminal mode |

### Clipboard
| Key | Mode | Action |
| --- | --- | --- |
| `<leader>y` | n/v/x | Yank to system clipboard |
| `<leader>Y` | n/v/x | Yank line to system clipboard |
| `<leader>p` | n/v/x | Paste from system clipboard |
| `<C-p>` | i | Paste from clipboard (insert mode) |
| `<leader>P` | x | Paste over selection, keep unnamed register |

### Buffers
| Key | Action |
| --- | --- |
| `<leader><leader>[` / `<leader><leader>]` | Previous / next buffer |
| `<leader><leader>l` | Last buffer |
| `<leader><leader>d` | Delete buffer |
| `<leader><leader>s` | Find existing buffers (Telescope) |

### Files & navigation
| Key | Action |
| --- | --- |
| `-` | Open parent directory (oil.nvim) |
| `<leader>-` | Open nvim root directory (oil.nvim) |
| `<leader>U` | Toggle Undotree |
| `<leader>ha` / `<leader>hh` | Harpoon add file / menu |
| `<leader>h1`–`<leader>h4` | Jump to Harpoon file 1–4 |
| `<leader>h[` / `<leader>h]` | Harpoon previous / next |

### Search (Telescope)
| Key | Action |
| --- | --- |
| `<leader>sf` | Files |
| `<leader>sg` | Live grep |
| `<leader>sp` | Grep git project root |
| `<leader>sw` | Current word |
| `<leader>sd` | Diagnostics |
| `<leader>sr` | Resume last picker |
| `<leader>s.` | Recent files |
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>ss` | Telescope builtins |
| `<leader>sM` | Notify messages |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader>s/` | Search in open files |

### LSP (active in buffers with an LSP attached)
| Key | Action |
| --- | --- |
| `gd` / `gD` | Goto definition / declaration |
| `gr` | Goto references |
| `gI` | Goto implementation |
| `K` | Hover docs |
| `<C-k>` | Signature help |
| `<leader>D` | Type definition |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cs` / `<leader>ws` | Document / workspace symbols |
| `<leader>wa` / `<leader>wr` / `<leader>wl` | Workspace folder add / remove / list |

### Diagnostics, format & lint
| Key | Action |
| --- | --- |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>e` | Open floating diagnostic |
| `<leader>q` | Diagnostics to loclist |
| `<leader>FF` | Format file (conform.nvim) |

*(Linting runs automatically on save via nvim-lint.)*

### Debugger (DAP)
| Key | Action |
| --- | --- |
| `<leader>dc` | Start / continue |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| `<leader>du` | Toggle DAP UI |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Set conditional breakpoint |

### Git (gitsigns)
| Key | Action |
| --- | --- |
| `]c` / `[c` | Next / previous hunk |
| `<leader>gs` / `<leader>gr` | Stage / reset hunk |
| `<leader>gS` / `<leader>gR` | Stage / reset buffer |
| `<leader>gu` | Undo stage hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |
| `<leader>gd` / `<leader>gD` | Diff against index / last commit |
| `<leader>gtb` / `<leader>gtd` | Toggle line blame / show deleted |
| `ih` | Select hunk (operator/visual) |

### Treesitter text objects & motions
| Key | Action |
| --- | --- |
| `<c-space>` | Start / expand incremental selection |
| `<c-s>` / `<M-space>` | Scope expand / shrink selection |
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside parameter |
| `]m` / `[m` | Next / previous function start |
| `]]` / `[[` | Next / previous class start |
| `<leader>a` / `<leader>A` | Swap parameter with next / previous |

### Markdown & Obsidian
| Key | Action |
| --- | --- |
| `<leader>mp` / `<leader>ms` / `<leader>mt` | Markdown preview start / stop / toggle |
| `<leader>oo` | Open in Obsidian |
| `<leader>od` | Daily note |
| `<leader>of` | Find note in vault |
| `<leader>ob` | Backlinks |
| `<leader>ol` | Note links |
| `<leader>ot` / `<leader>oT` | Insert template / table of contents |
| `<leader>oc` | Toggle checkbox (in note) |

### LaTeX (vimtex)
| Key | Action |
| --- | --- |
| `<leader>lc` | Compile |
| `<leader>lv` | View PDF |
| `<leader>le` | Show errors |
| `<leader>ls` | Stop compiler |
| `<leader>lt` | Toggle TOC |
| `<leader>lw` | Word count |

### AI (claude-code.nvim)
| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ac` | n | Toggle Claude Code |
| `<leader>af` | n | Focus Claude Code |
| `<leader>as` | v | Send selection to Claude |
| `<leader>aa` / `<leader>ad` | n | Accept / deny diff |

## TODO
* move files from myLuaConf to a regular structure (use `plugin/` and `ftplugin/` maybe)
* Learn what the debugger, linter, and formatter do
* switch from `lze` to `lz.n`
