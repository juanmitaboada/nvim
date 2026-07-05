-- ~/.config/nvim/lua/options.lua
--
-- Direct translation of the `set X` lines from the previous .vimrc to
-- Neovim's Lua API. `vim.opt` is the modern equivalent of :set.

local opt = vim.opt

-- === Basic editing ===
opt.backspace   = { "indent", "eol", "start" }  -- allow backspacing over everything (old `set bs=2`)
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.softtabstop = 4
opt.expandtab   = true                          -- spaces, not tabs
opt.textwidth   = 0                             -- don't wrap lines by default
opt.linebreak   = true                          -- don't break words if wrap is on
opt.autowrite   = true                          -- write the file when switching buffers
opt.autoread    = true                          -- reload file if it changed on disk

-- === Display ===
opt.number     = true                           -- show line numbers
opt.ruler      = true                           -- show cursor position at all times
opt.showcmd    = true                           -- show partial command in the status line
opt.showmatch  = true                           -- highlight matching brackets
opt.laststatus = 2                              -- statusline always visible (lualine overrides this)
opt.cursorline = false                          -- don't highlight current line (flip to true if preferred)
opt.signcolumn = "yes"                          -- always-visible gutter (avoids jitter when signs appear)

-- === Search ===
opt.incsearch  = true                           -- incremental search
opt.hlsearch   = true                           -- highlight all matches
opt.ignorecase = true                           -- case-insensitive search...
opt.smartcase  = true                           -- ...unless the query contains uppercase

-- === Buffers and history ===
opt.hidden  = true                              -- allow modified hidden buffers
opt.history = 100

-- === Folding ===
opt.foldmethod  = "indent"                      -- ideal for Python, as before
opt.foldnestmax = 10
opt.foldenable  = false                         -- don't fold on open (old `set nofoldenable`)
opt.foldlevel   = 1

-- === Visible characters (old `set list` + `lcs`) ===
opt.list      = true
opt.listchars = { extends = "$", tab = "/.", eol = "$" }
opt.encoding  = "utf-8"

-- === Mouse ===
opt.mouse = "a"                                 -- enable mouse in all modes

-- === Completion ===
opt.completeopt = { "menu", "menuone", "noselect" }  -- better UX with nvim-cmp

-- === Performance ===
opt.updatetime = 300                            -- faster CursorHold and gitsigns (default 4000)
opt.timeoutlen = 500                            -- wait time for key sequences

-- === Safety (old exrc + secure) ===
opt.exrc   = true                               -- allow project-local .nvimrc
opt.secure = true                               -- restrict what project-local rc files can do

-- === Shada (Neovim's equivalent of viminfo) ===
opt.shada = { "'20", "\"50" }                   -- equivalent to old 'viminfo='20,"50'

-- === Split windows (sensible defaults) ===
opt.splitbelow = true                           -- horizontal splits open below
opt.splitright = true                           -- vertical splits open to the right

-- === Personal abbreviation (old `ab usetab`) ===
vim.cmd([[ab usetab :set noet ci pi sts=0 sw=4 ts=4]])
