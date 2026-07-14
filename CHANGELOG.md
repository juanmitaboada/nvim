# Changelog

All notable changes to this configuration are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/).

## 1.1.1 — Require Neovim 0.11.3 — 2026-07-14

### Added

- **README: "Installing Neovim without sudo (AppImage)"** — step-by-step for
  user-only machines, including the `PATH` ordering and `hash -r` gotcha that
  makes a system `nvim` in `/usr/bin` shadow the newer AppImage.

### Fixed

- **Corrected the minimum Neovim version to 0.11.3** (it was wrongly documented
  and checked as 0.10). The `unokai` colorscheme is a 0.11 addition, and the LSP
  stack now uses `vim.lsp.enable()` / `vim.lsp.config()` (since 0.11.0) with
  nvim-lspconfig requiring 0.11.3+. On 0.10 the config aborted with
  `E185: Cannot find color scheme 'unokai'` followed by `nil` `vim.lsp.*` errors.
  `install-neovim.sh` now enforces `>= 0.11.3` (patch-aware) and points at both
  the Neovim PPA and the sudo-free AppImage.
- **`init.lua` falls back gracefully** if `unokai` is unavailable (`pcall` to
  `habamax`) instead of aborting startup with `E185`.

## 1.1.0 — Optional Copilot & WakaTime — 2026-07-14

> **Heads-up for upgraders:** GitHub Copilot and WakaTime are now **off by
> default**. After pulling this version they stop loading until you opt back in
> on this machine. Create `~/.config/nvim/lua/local.lua` with:
>
> ```lua
> return { copilot = true, wakatime = true }
> ```
>
> then run `:Lazy sync` (or restart Neovim). Re-running `install-neovim.sh` does
> this for you. Per-flag details in the README's "Optional features" section.

### Added

- **Optional, account-bound plugins** (`lua/features.lua`). GitHub Copilot
  (`copilot.vim` + `CopilotChat.nvim`) and WakaTime (`vim-wakatime`) are now
  **off by default**: on a fresh checkout, a server, or another person's
  machine they are neither installed nor loaded. A machine opts in per feature
  via a git-ignored `lua/local.lua` (e.g. `return { copilot = true, wakatime = true }`),
  which overrides the defaults. Each plugin is gated with lazy.nvim's
  `enabled = ...`, and the Copilot Chat keymaps are guarded by the same flag so
  nothing maps to missing commands when it's disabled.
- **Bootstrap prompt** for the optional features: `install-neovim.sh` now offers
  to create `lua/local.lua` before syncing plugins, and prints the `:Copilot
  setup` reminder only when Copilot is actually enabled.

### Changed

- **Copilot and WakaTime default to off.** Previously both loaded unconditionally;
  they are now opt-in per machine (see the upgrade note above).
- **Node.js + npm** are now an optional requirement, needed only when Copilot is
  enabled.

## 1.0.0 — Initial release

First public release of my Neovim configuration: a Lua setup built on
lazy.nvim, with native LSP, Treesitter, Telescope and GitHub Copilot, and a
Python-first workflow.

### Added

- **Plugin management** via lazy.nvim, bootstrapped automatically on first run.
- **Native LSP** (nvim-lspconfig) with servers auto-installed by Mason:
  basedpyright, ruff, clangd, rust_analyzer, zls, bashls, yamlls, lua_ls,
  marksman and dockerls. Buffer-local keymaps on attach (`gd`, `gr`, `gi`, `K`,
  `<leader>rn`, `<leader>ca`, `<leader>ws`), with `Enter` mapped to go-to-definition
  in normal file buffers.
- **Completion** with nvim-cmp (LSP, buffer, path and snippet sources).
- **Snippets** via LuaSnip and the friendly-snippets collection (`F2` to expand,
  `<C-b>` / `<C-z>` to jump).
- **AI assistance** with GitHub Copilot inline suggestions (`Tab` to accept,
  `F12` for the panel) and Copilot Chat (`<leader>cc`, plus explain/fix/review on
  a visual selection).
- **Fuzzy finding** with Telescope + fzf-native: files (`<C-p>` / `<leader>ff`),
  live grep (`<leader>fg`), buffers (`<leader>fb`), help and resume.
- **File tree** (nvim-tree, `F4`) and **symbol outline** (aerial, `F3`).
- **Git integration**: gitsigns in the gutter and fugitive commands
  (`<leader>gs` / `gb` / `gd`), with hunk navigation.
- **Formatting** with conform.nvim (black, shfmt, clang-format, …) and
  **linting** with nvim-lint.
- **Per-project tooling**: pylint runs only when the project opts in; mypy runs
  on demand via `:Mypy` / `<leader>m`, sending results to the quickfix list.
- **UI**: lualine statusline, indent-blankline guides, which-key popup, devicons,
  and the builtin `unokai` colorscheme.
- **Editing quality of life**: autopairs, commentary, surround, repeat and
  unimpaired; line/block move and indent; JSON reformat (`<C-j>`); session save
  (`F8`).
- **Bootstrap script** (`install-neovim.sh`) that installs system packages,
  bridges `fd` on Debian/Ubuntu, checks the Neovim version, links the repo into
  `~/.config/nvim` and pre-syncs plugins.
- **Documentation**: README with feature screenshots, a full shortcut reference
  and installation instructions.

### Requirements

- Neovim >= 0.10 (the `unokai` colorscheme is a builtin from 0.10 onwards).
- git, make, gcc, Node.js + npm, ripgrep, fd, and a Nerd Font.
