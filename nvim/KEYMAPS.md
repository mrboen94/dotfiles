# Neovim Configuration & Keymaps

Leader key: `<Space>`

## Table of Contents

- [File Operations](#file-operations)
- [Window Management](#window-management)
- [Navigation](#navigation)
- [Editor](#editor)
- [Search & Find](#search--find)
- [Git](#git)
- [Task Runner](#task-runner)
- [Debugging](#debugging)
- [Diagnostics & Errors](#diagnostics--errors)
- [Quick File Switching](#quick-file-switching)
- [Plugins](#plugins)

---

## File Operations

| Key                 | Action           |
| ------------------- | ---------------- |
| `<leader>fs`        | Save file        |
|| `<leader>ff`        | Format file      |
| `<C-f>`             | Format file      |
| `<leader>qq`        | Quit             |
| `<leader>qs`        | Save and quit    |
| `<leader>qf`        | Force quit       |
| `<leader>qa`        | Quit all (force) |

## Window Management

### Basic Splits

| Key          | Action           |
| ------------ | ---------------- |
| `<leader>wV` | Vertical split   |
| `<leader>wH` | Horizontal split |

### Directional Splits

| Key           | Action      |
| ------------- | ----------- |
| `<leader>wsh` | Split left  |
| `<leader>wsl` | Split right |
| `<leader>wsj` | Split below |
| `<leader>wsk` | Split above |

### Window Navigation

| Key          | Action             |
| ------------ | ------------------ |
| `<leader>ww` | Go to other window |
| `<leader>wh` | Window left        |
| `<leader>wj` | Window down        |
| `<leader>wk` | Window up          |
| `<leader>wl` | Window right       |
| `<C-h>`      | Move focus left    |
| `<C-j>`      | Move focus down    |
| `<C-k>`      | Move focus up      |
| `<C-l>`      | Move focus right   |

### Window Closing

| Key           | Action               |
| ------------- | -------------------- |
| `<leader>wqq` | Close current window |
| `<leader>wqo` | Close other windows  |

## Navigation

### Better Scrolling (auto-centers cursor)

| Key     | Action                   |
| ------- | ------------------------ |
| `<C-d>` | Scroll down + center     |
| `<C-u>` | Scroll up + center       |
| `n`     | Next search + center     |
| `N`     | Previous search + center |

### Flash Navigation

| Key           | Action                  |
| ------------- | ----------------------- |
| `s` + 2 chars | Jump anywhere on screen |
| `S`           | Treesitter-aware jump   |

### Quickfix & Diagnostics

| Key          | Action              |
| ------------ | ------------------- |
| `<leader>fj` | Next quickfix       |
| `<leader>fk` | Previous quickfix   |
| `<leader>fl` | Next diagnostic     |
| `<leader>fh` | Previous diagnostic |

## Editor

| Key     | Action                                   |
| ------- | ---------------------------------------- |
| `<C-c>` | Copy to system clipboard (normal/visual) |
| `<C-l>` | Toggle relative line numbers             |
| `<Esc>` | Clear search highlights                  |

## Search & Find (Telescope)

| Key                | Action                         |
| ------------------ | ------------------------------ |
| `<leader>sh`       | Search help                    |
| `<leader>sk`       | Search keymaps                 |
| `<leader>sf`       | Search files                   |
| `<leader>ss`       | Search select Telescope        |
| `<leader>sw`       | Search current word            |
| `<leader>sg`       | Search by grep                 |
| `<leader>sd`       | Search diagnostics             |
| `<leader>sr`       | Search resume                  |
| `<leader>s.`       | Search recent files            |
| `<leader><leader>` | Find existing buffers          |
| `<leader>/`        | Fuzzy search in current buffer |
| `<leader>s/`       | Search in open files           |
| `<leader>sn`       | Search Neovim config files     |

## Git

| Key          | Action          |
| ------------ | --------------- |
| `<leader>gb` | Git blame line  |
| `<leader>gd` | Git diff        |
| `<leader>gp` | Preview hunk    |
| `<leader>gh` | Reset hunk      |
| `<leader>gs` | Stage hunk      |
| `<leader>gu` | Undo stage hunk |

## Task Runner

Automatically detects project type (npm, Cargo, Go, Make, Odin, Python)

| Key          | Action                   |
| ------------ | ------------------------ |
| `<leader>rb` | Build                    |
| `<leader>rr` | Run/Dev                  |
| `<leader>rt` | Test                     |
| `<leader>rl` | Lint                     |
| `<leader>ro` | Toggle task output panel |
| `<leader>ra` | Run any task (picker)    |

### Supported Commands

- **JavaScript/TypeScript**: `npm run build/dev/test/lint`
- **Rust**: `cargo build/run/test/clippy`
- **Go**: `go build/run/test`
- **Odin**: `odin build/run/test`
- **Python**: `python <file>` / `pytest`
- **Make**: `make`

## Debugging

### Session Control

| Key          | Action                              |
| ------------ | ----------------------------------- |
| `<leader>rd` | Start debugging (Run with Debugger) |
| `<leader>dc` | Continue execution                  |
| `<leader>dt` | Terminate session                   |
| `<leader>dr` | Restart session                     |

### Breakpoints

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>db` | Toggle breakpoint      |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dl` | Log point              |

### Stepping

| Key           | Action    |
| ------------- | --------- |
| `<leader>dsi` | Step into |
| `<leader>dso` | Step over |
| `<leader>dsu` | Step out  |

### Inspection

| Key          | Action                              |
| ------------ | ----------------------------------- |
| `<leader>dh` | Hover (show variable value)         |
| `<leader>dp` | Preview variable                    |
| `<leader>de` | Evaluate expression (normal/visual) |

### Debug UI

| Key           | Action                |
| ------------- | --------------------- |
| `<leader>du`  | Toggle debug UI       |
| `<leader>duo` | Open debug UI         |
| `<leader>duc` | Close debug UI        |
| `<leader>dur` | Reset debug UI layout |

### Debugger Support

- **Mac/Linux**: lldb (via codelldb)
- **Windows**: RAD Debugger (remedybg)
- **Languages**: C, C++, Rust, Odin, Go

## Diagnostics & Errors (Trouble)

| Key          | Action                   |
| ------------ | ------------------------ |
| `<leader>xx` | Toggle diagnostics panel |
| `<leader>xq` | Quickfix list            |
| `<leader>xl` | Location list            |

## Quick File Switching (Harpoon)

| Key          | Action                      |
| ------------ | --------------------------- |
| `<leader>ha` | Add current file to harpoon |
| `<leader>hh` | Open harpoon menu           |
| `<leader>1`  | Jump to file 1              |
| `<leader>2`  | Jump to file 2              |
| `<leader>3`  | Jump to file 3              |
| `<leader>4`  | Jump to file 4              |
| `<leader>5`  | Jump to file 5              |

**Usage**: Mark 4-5 files you're actively working on, then switch instantly with number keys.

## Arrow (Alternative File Switcher)

| Key | Action                           |
| --- | -------------------------------- |
| `ø` | Open Arrow global bookmarks      |
| `å` | Open Arrow buffer bookmarks      |
| `'` | Reveal current file in Neo-tree  |

## Wezterm Integration

| Key           | Action                            |
| ------------- | --------------------------------- |
| `<leader>wpr` | Reset Wezterm font size to 18     |
| `<leader>wps` | Set custom Wezterm font size      |
| `<leader>wpp` | Change Wezterm font               |

## Plugins

### Core Plugins

#### lazy.nvim
Plugin manager that handles installation and lazy-loading.
- Automatically installs plugins on first run
- Only loads plugins when needed for better startup time
- `:Lazy` to manage plugins

#### which-key.nvim
Keymap helper that shows available keys.
- Press `<Space>` and wait 300ms to see available commands
- Groups commands logically (w=window, f=find, g=git, etc.)
- Self-documenting keybinds

#### nvim-treesitter
Advanced syntax highlighting and code understanding.
- Better syntax highlighting than regex-based
- Powers indent, folding, text objects
- Auto-installs parsers for opened file types

#### LSP Stack (nvim-lspconfig, mason)
Language server protocol support for IDE features.
- **mason.nvim**: GUI package manager for LSP servers
- **mason-lspconfig**: Auto-setup installed servers
- **mason-tool-installer**: Auto-install configured tools
- Provides: autocomplete, go-to-definition, hover docs, diagnostics
- `:Mason` to install servers

#### blink.cmp
Fast, modern completion engine.
- **Super-tab** preset: Tab to accept completion
- Auto-shows documentation after 500ms
- Integrates with LSP, snippets, file paths
- **LuaSnip**: Snippet engine with friendly-snippets collection

#### conform.nvim
Code formatting with multiple formatters.
- Auto-formats on save (except C/C++)
- Per-filetype formatters (Prettier for JS/TS, stylua for Lua)
- `<leader>ff` or `<C-f>` to format manually

### File & Search

#### telescope.nvim
Fuzzy finder for everything.
- Search files, text, buffers, help, keymaps
- **telescope-fzf-native**: Native FZF for faster sorting
- **telescope-ui-select**: Better vim.ui.select interface
- All keybinds under `<leader>s`

#### neo-tree.nvim
Modern file explorer with git status.
- Shows on right side, 30 columns wide
- Git status indicators (added, modified, staged)
- `<leader>tt` to toggle, `'` to reveal current file
- Many file operations: create, delete, rename, copy

#### flash.nvim
Jump to any location with 2 characters.
- `s` + 2 chars: jump anywhere on screen
- `S`: treesitter-aware jump (functions, classes)
- Faster than f/t/w/b motions

#### arrow.nvim
Persistent file bookmarks (Norwegian keyboard friendly).
- `ø`: global bookmarks across all projects
- `å`: buffer-specific bookmarks
- Saves across Neovim sessions
- Alternative to Harpoon with different UX

### Git Integration

#### gitsigns.nvim
Git indicators and operations.
- Shows +/~/- in gutter for changes
- Stage/unstage/reset hunks
- Blame line, preview changes, diff
- All operations under `<leader>g`

### Development Tools

#### overseer.nvim
Task runner with project auto-detection.
- Detects: npm, Cargo, Go, Make, Odin, Python
- Runs: build, dev/run, test, lint commands
- Shows output in toggleable split
- `<leader>ro` to toggle output panel

#### nvim-dap (Debug Adapter Protocol)
Full debugging with breakpoints and stepping.
- Breakpoints, conditional breakpoints, log points
- Step into/over/out, continue, restart
- Variable inspection, hover values, expression eval
- Platform-specific: lldb (Mac/Linux), RAD debugger (Windows)
- Supports: C, C++, Rust, Odin, Go

#### nvim-dap-ui
Beautiful debugging interface.
- Auto-opens when debugging starts
- Shows: variables, watches, stack, breakpoints, console
- Resizable panels, customizable layout
- `<leader>du` to toggle

#### nvim-dap-virtual-text
Inline variable values during debugging.
- Shows variable values next to code
- Updates in real-time while stepping
- No need to hover or check watch window

#### mason-nvim-dap
Auto-install debug adapters.
- Installs codelldb for C/C++/Rust/Odin
- Integrates with Mason package manager

### UI/UX Enhancement

#### trouble.nvim
Better diagnostics and quickfix interface.
- Prettier display than default quickfix
- Groups by severity, file, type
- `<leader>xx` for diagnostics, `<leader>xq` for quickfix

#### harpoon (v2)
Quick file switcher with numbered marks.
- Mark up to 5 active files
- Switch instantly with `<leader>1-5`
- Faster than Telescope for active files
- `<leader>ha` to add, `<leader>hh` for menu

#### todo-comments.nvim
Highlight special comments.
- Colorful highlighting for TODO, FIXME, NOTE, HACK, WARN
- Search all TODOs with `:TodoTelescope`

#### mini.nvim (Collection)
Multiple small, independent plugins.
- **mini.ai**: Enhanced text objects (better `vi)`, `va{`)
- **mini.surround**: Add/delete/change surroundings
  - `saiw)`: surround word with ()
  - `sd'`: delete surrounding ''
  - `sr)'`: replace () with ''
- **mini.statusline**: Fast, clean statusline

#### neoscroll.nvim
Smooth scrolling animations.
- Makes `<C-d>`, `<C-u>`, `<C-f>`, `<C-b>` smooth
- Configurable speed and easing (500ms, quadratic)
- All windows scroll together

#### smear-cursor.nvim
Smooth cursor movement with trail.
- Cursor leaves animated trail
- Easier to track cursor movement
- Different settings for insert vs normal mode

#### nvim-highlight-colors
Inline color preview.
- Shows color preview for hex (#ff0000)
- RGB, HSL, Tailwind color names
- Helps visualize colors in code

#### nvim-window-picker
Easy window selection.
- Shows letters on windows for quick jumping
- Used by Neo-tree for file opening
- Alternative to `<C-w><C-w>`

#### wezterm-config.nvim
Control Wezterm from Neovim.
- Change font, font size from Neovim
- Settings persist in Wezterm config
- `<leader>wp` prefix for Wezterm commands

### Utility Plugins

#### guess-indent.nvim
Auto-detect indentation.
- Detects tabs vs spaces
- Detects indent width (2, 4, 8)
- No manual configuration needed

#### nvim-autopairs
Auto-close brackets and quotes.
- Closes (, [, {, ", ', `
- Smart deletion (deletes both pair)
- Integrates with completion

#### indent-blankline
Indentation guides.
- Vertical lines showing indent levels
- Helpful for Python, YAML, JSON
- Shows current scope

#### nvim-nio
Async IO library for plugins.
- Core dependency for nvim-dap-ui
- Provides async operations
- Used by multiple plugins

#### nvim-web-devicons
File type icons.
- Shows icons in trees, menus, statusline
- Requires Nerd Font
- Used by most UI plugins

#### nui.nvim
UI component library.
- Popups, splits, inputs, menus
- Used by Neo-tree
- Foundation for plugin UIs

---

## Configuration Structure

```
nvim/
├── init.lua                    # Main config
├── lua/
│   └── custom/
│       └── plugins/
│           ├── remap.lua       # All keymaps
│           ├── task-runner.lua # Overseer config
│           ├── debug.lua       # DAP config
│           ├── trouble.lua     # Trouble config
│           ├── flash.lua       # Flash config
│           ├── harpoon.lua     # Harpoon config
│           └── ...             # Other plugins
└── KEYMAPS.md                  # This file
```

## Tips

1. **Press `<leader>` and wait** - which-key will show all available commands
2. **Use Flash (`s`)** instead of `w/b/f/t` for faster navigation
3. **Mark frequently used files with Harpoon** for instant access
4. **Use Trouble (`<leader>xx`)** instead of default quickfix
5. **Center cursor while scrolling** - already mapped to `<C-d>/<C-u>`
6. **Conditional breakpoints** - Set breakpoints that only trigger when a condition is true
7. **Evaluate expressions in debug** - Select text in visual mode and press `<leader>de`

## Customization

Edit keymaps in: `~/.config/nvim/lua/custom/plugins/remap.lua`
