# Changelog

All notable changes to this configuration are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/).

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
