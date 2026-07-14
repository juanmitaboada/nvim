-- ~/.config/nvim/lua/plugins/ai.lua
--
-- Copilot (official) + CopilotChat (native Neovim).
--
-- Both plugins are OPTIONAL and OFF by default (see lua/features.lua): on a
-- fresh checkout, or on a machine that is not mine, Copilot is neither cloned
-- nor loaded. A machine opts in via a git-ignored lua/local.lua. The single
-- `features.copilot` switch gates copilot.vim AND CopilotChat (which depends
-- on it); the matching keymaps in lua/keymaps.lua are guarded by the same flag.

local features = require("features")

return {

    -- ============================================================
    -- COPILOT — official GitHub plugin
    --
    -- Loaded eagerly (lazy = false). Reason: with `event = "InsertEnter"`,
    -- lazy.nvim was not registering the loader correctly for this Vimscript
    -- plugin, leaving :Copilot undefined at runtime (only the CopilotChat*
    -- prefix-stubs from the chat plugin existed, which made `:Copilot status`
    -- fail with E464 "Ambiguous use of user-defined command"). Eager loading
    -- is cheap here and guarantees the agent is up before the first edit.
    --
    -- Default behavior:
    --   - Inline suggestions appear automatically while typing.
    --   - <Tab> accepts the inline suggestion (Copilot's native default).
    --     nvim-cmp does not map <Tab> (see plugins/lsp.lua), so there's no clash.
    --
    -- Manual trigger we add:
    --   <F12> in normal or insert mode → open the panel with multiple alternatives.
    --
    -- Note on forcing inline suggestions: the current copilot.vim does not
    -- expose a public command to force one. If the automatic suggestion does
    -- not appear, the practical workaround is to delete the last character and
    -- retype it, which re-triggers the suggestion engine.
    -- ============================================================
    {
        "github/copilot.vim",
        enabled = features.copilot,
        lazy = false,
        config = function()
            -- Open the Copilot panel showing several alternative suggestions
            -- for the current context. Pick one with <CR>, dismiss with q.
            -- Mapped in both normal and insert mode so it's reachable mid-edit
            -- without having to exit insert first.
            vim.keymap.set({ "n", "i" }, "<F12>", "<Cmd>Copilot panel<CR>", {
                silent = true,
                desc = "Copilot: open panel with alternatives",
            })

            -- First-time sign-in: run :Copilot setup
        end,
    },

    -- ============================================================
    -- COPILOT CHAT — native Neovim replacement for DanBradbury/copilot-chat.vim
    -- ============================================================
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        enabled = features.copilot,
        dependencies = {
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim" },
        },
        branch = "main",
        cmd = {
            "CopilotChat", "CopilotChatOpen", "CopilotChatToggle",
            "CopilotChatExplain", "CopilotChatReview", "CopilotChatFix",
            "CopilotChatOptimize", "CopilotChatDocs", "CopilotChatTests",
        },
        keys = { "<leader>cc", "<leader>ce", "<leader>cr", "<leader>cf" },
        build = "make tiktoken",
        config = function()
            require("CopilotChat").setup({
                model = "claude-sonnet-4.5",   -- list the available ones with :CopilotChatModels
                window = {
                    layout = "vertical",       -- vertical split to the right
                    width = 0.4,
                },
                show_help = true,
                auto_follow_cursor = false,
                mappings = {
                    complete = { insert = "<C-y>" },  -- not Tab, to avoid stealing it from Copilot
                    close = { normal = "q", insert = "<C-c>" },
                    reset = { normal = "<C-r>", insert = "<C-r>" },
                    submit_prompt = { normal = "<CR>", insert = "<C-s>" },
                },
            })
        end,
    },

}
