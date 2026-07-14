-- ~/.config/nvim/init.lua
--
-- Entry point. Keep this short: it only loads the modules.
-- All real configuration lives in lua/*.lua

-- Leader key must be set before anything else. Otherwise, mappings that
-- use <leader> will bind against the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load modules in order: options, plugins (via lazy), keymaps, autocmds.
-- keymaps and autocmds come after plugins because some mappings depend on
-- plugins being loaded first.
require("options")
require("lazy-bootstrap")
require("lazy").setup(require("plugins"))
require("keymaps")
require("autocmds")
require("commands.mypy")
-- `unokai` is a builtin colorscheme added in Neovim 0.11. The install script
-- enforces >= 0.11.3, but guard here too so a stray older nvim degrades to a
-- safe builtin instead of aborting init.lua with E185.
if not pcall(vim.cmd.colorscheme, "unokai") then
    pcall(vim.cmd.colorscheme, "habamax")
end
