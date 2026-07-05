-- ~/.config/nvim/lua/autocmds.lua
--
-- Translation of the .vimrc autocmds.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ========================================================================
-- Remember last cursor position (old BufReadPost autocmd)
-- ========================================================================
autocmd("BufReadPost", {
    group = augroup("RememberPosition", { clear = true }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- ========================================================================
-- Clear screen on exit (old :!clear on VimLeave)
-- ========================================================================
autocmd("VimLeave", {
    group = augroup("ClearOnExit", { clear = true }),
    command = "!clear",
})

-- ========================================================================
-- Flash the yanked region briefly (a small bonus that is genuinely useful)
-- ========================================================================
autocmd("TextYankPost", {
    group = augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.hl.on_yank({ timeout = 200 })
    end,
})

-- ========================================================================
-- Diff mode tweaks (replaces the old `if &diff` block)
-- ========================================================================
autocmd("OptionSet", {
    group = augroup("DiffConfig", { clear = true }),
    pattern = "diff",
    callback = function()
        if vim.o.diff then
            vim.opt.cursorline = true
            vim.keymap.set("n", "]", "]c", { buffer = true })
            vim.keymap.set("n", "[", "[c", { buffer = true })
        end
    end,
})

-- ========================================================================
-- NOTE on format-on-save for Python:
--   The old .vimrc had `autocmd BufWritePre *.py Black`.
--   That job is now handled by conform.nvim (see plugins/lsp.lua).
--   Conform is async, does not block the save, and also handles clang-format,
--   shfmt, etc. — a single mechanism for every formatter.
-- ========================================================================

-- -- ========================================================================
-- Diagnostic floats: override colors for readability on unokai
--   The default DiagnosticFloating* groups inherit a dark red that has
--   very low contrast against unokai's dark background. We override with
--   brighter pastel tones + bold. Registered as a ColorScheme autocmd so
--   the overrides reapply automatically if the colorscheme changes.
-- ========================================================================
autocmd("ColorScheme", {
    group = augroup("DiagnosticFloatColors", { clear = true }),
    callback = function()
        vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = "#ff8787", bold = true })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = "#ffd787", bold = true })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = "#87d7ff", bold = true })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = "#87ffaf", bold = true })
    end,
})

-- Trigger now because the colorscheme is already loaded when this file runs
vim.cmd("doautocmd ColorScheme")
