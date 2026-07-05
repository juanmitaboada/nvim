-- ~/.config/nvim/lua/keymaps.lua
--
-- All original .vimrc hotkeys preserved + new bindings for LSP and Telescope.
-- `vim.keymap.set` is the modern equivalent of :map / :nmap / etc.

local map = vim.keymap.set
local opts = { silent = true, noremap = true }

-- ========================================================================
-- CLASSIC HOTKEYS (from the old .vimrc)
-- ========================================================================

-- F3: Tagbar toggle -> now aerial (LSP-based outline)
map("n", "<F3>", ":AerialToggle<CR>", opts)
map("i", "<F3>", "<Esc>:AerialToggle<CR>", opts)

-- F4: NERDTree toggle -> now nvim-tree
map("n", "<F4>", ":NvimTreeToggle<CR>", opts)
map("i", "<F4>", "<Esc>:NvimTreeToggle<CR>", opts)

-- F8: Save session
map("n", "<F8>", ":mks! .session.vim<CR>", opts)

-- Ctrl+J: Format JSON (classic trick)
map("n", "<C-j>", ":%!python3 -m json.tool<CR>", opts)

-- Enter = go to definition, Backspace = pop tag stack.
-- With LSP, Enter runs vim.lsp.buf.definition(), smarter than ctags.
--
-- IMPORTANT: in special buffers (quickfix/location list, the command-line
-- window, help, etc.) Enter has its own built-in meaning — jumping to the
-- quickfix entry under the cursor, executing the command in the cmdwin, and
-- so on. Remapping <CR> globally shadows all of that, which silently breaks
-- quickfix navigation (e.g. the :Mypy results list). So we only take over
-- Enter in real file buffers (buftype == "") and outside the cmdwin; anywhere
-- else we feed the native <CR> through untouched.
map("n", "<CR>", function()
    if vim.bo.buftype ~= "" or vim.fn.getcmdwintype() ~= "" then
        local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        vim.api.nvim_feedkeys(cr, "n", false)
        return
    end
    vim.lsp.buf.definition()
end, opts)
map("n", "<BS>", "<C-t>", opts)

-- ========================================================================
-- BUFFERS (Alt + arrows, as before)
-- ========================================================================

-- Alt+Up: BufExplorer -> Telescope buffers (faster and richer)
map("n", "<A-Up>", ":Telescope buffers<CR>", opts)
map("i", "<A-Up>", "<Esc>:Telescope buffers<CR>", opts)

-- Alt+Right: next buffer
map("n", "<A-Right>", ":bnext<CR>", opts)
map("i", "<A-Right>", "<Esc>:bnext<CR>", opts)

-- Alt+Left: previous buffer
map("n", "<A-Left>", ":bprevious<CR>", opts)
map("i", "<A-Left>", "<Esc>:bprevious<CR>", opts)

-- Alt+Down: close buffer
map("n", "<A-Down>", ":bd<CR>", opts)
map("i", "<A-Down>", "<Esc>:bd<CR>", opts)

-- ========================================================================
-- MOVE LINES (Ctrl + arrows, as before)
-- ========================================================================

-- Ctrl+Down/Up: move line up/down
map("n", "<C-Down>", ":m+<CR>==", opts)
map("n", "<C-Up>", ":m-2<CR>==", opts)
map("i", "<C-Down>", "<Esc>:m+<CR>==gi", opts)
map("i", "<C-Up>", "<Esc>:m-2<CR>==gi", opts)
map("v", "<C-Down>", ":m'>+<CR>gv=gv", opts)
map("v", "<C-Up>", ":m-2<CR>gv=gv", opts)

-- Ctrl+Right/Left: indent / unindent line or selection
map("n", "<C-Left>", "v<<Esc>", opts)
map("n", "<C-Right>", "v><Esc>", opts)
map("i", "<C-Left>", "<Esc>v<<Esc>gi", opts)
map("i", "<C-Right>", "<Esc>v><Esc>gi", opts)
map("v", "<C-Left>", "<gv", opts)
map("v", "<C-Right>", ">gv", opts)

-- In visual mode, < and > keep the selection
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- ========================================================================
-- DIAGNOSTICS (replaces ALE's [a / ]a)
-- ========================================================================

-- vim.diagnostic.goto_prev/goto_next were deprecated in Neovim 0.11 in favour
-- of vim.diagnostic.jump{count=...}. These helpers keep the old move-and-float
-- behaviour under the same keys.
local diag_prev = function() vim.diagnostic.jump({ count = -1, float = true }) end
local diag_next = function() vim.diagnostic.jump({ count = 1, float = true }) end

-- [d / ]d navigates diagnostics (errors/warnings) — Neovim LSP standard
map("n", "[d", diag_prev, opts)
map("n", "]d", diag_next, opts)

-- [a / ]a also navigates diagnostics (muscle memory)
map("n", "[a", diag_prev, opts)
map("n", "]a", diag_next, opts)

-- Ctrl+Shift+Left/Right also navigates diagnostics
map("n", "<C-S-Left>", diag_prev, opts)
map("n", "<C-S-Right>", diag_next, opts)

-- Show the full message of the diagnostic under the cursor
map("n", "<leader>e", vim.diagnostic.open_float, opts)

-- ========================================================================
-- LSP (buffer-local bindings live in plugins/lsp.lua on_attach)
-- ========================================================================

-- ========================================================================
-- TELESCOPE (replaces CtrlP, Ack, BufExplorer)
-- ========================================================================

map("n", "<leader>ff", ":Telescope find_files<CR>", opts)   -- find files
map("n", "<leader>fg", ":Telescope live_grep<CR>", opts)    -- grep content (replaces :Ack)
map("n", "<leader>fb", ":Telescope buffers<CR>", opts)      -- buffers
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts)    -- help
map("n", "<leader>fr", ":Telescope resume<CR>", opts)       -- resume last search
map("n", "<C-p>", ":Telescope find_files<CR>", opts)        -- CtrlP muscle memory

-- ========================================================================
-- GIT (fugitive)
-- ========================================================================

map("n", "<leader>gs", ":Git<CR>", opts)        -- status
map("n", "<leader>gb", ":Git blame<CR>", opts)  -- blame
map("n", "<leader>gd", ":Gdiffsplit<CR>", opts) -- diff

-- ========================================================================
-- COPILOT CHAT
-- ========================================================================

map("n", "<leader>cc", ":CopilotChat<CR>", opts)
map("v", "<leader>cc", ":CopilotChat<CR>", opts)
map("n", "<leader>ce", ":CopilotChatExplain<CR>", opts)
map("v", "<leader>ce", ":CopilotChatExplain<CR>", opts)
map("v", "<leader>cr", ":CopilotChatReview<CR>", opts)
map("v", "<leader>cf", ":CopilotChatFix<CR>", opts)
