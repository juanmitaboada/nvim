-- ~/.config/nvim/lua/plugins/coding.lua
--
-- Low-level code tooling: highlighting, snippets, tpope utilities, autopairs.

return {

    -- ============================================================
    -- TREESITTER — real syntax highlighting (replaces regex-based highlighting)
    -- ============================================================
    {
        "nvim-treesitter/nvim-treesitter",
        -- Pinned to the last formal release of the classic API (v0.9.3).
        -- The plugin's `main` branch introduced a new API that requires the
        -- tree-sitter CLI and is still evolving; `master` is deprecated.
        -- This tag is immutable and will not change, giving us full stability.
        tag = "v0.9.3",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "python", "c", "cpp", "rust", "zig",
                    "javascript", "typescript", "html", "css",
                    "bash", "yaml", "json", "toml", "markdown", "markdown_inline",
                    "dockerfile", "lua", "vim", "vimdoc", "query",
                    "regex", "comment", "gitcommit", "diff",
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        node_decremental = "<bs>",
                    },
                },
            })
        end,
    },

    -- ============================================================
    -- SNIPPETS — LuaSnip + friendly-snippets (replaces UltiSnips)
    -- Integration with nvim-cmp lives in plugins/lsp.lua
    -- ============================================================
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = "InsertEnter",
        -- F2 triggers snippet expansion, mirroring the old UltiSnips binding
        keys = {
            { "<F2>", function() require("luasnip").expand() end, mode = "i", desc = "Expand snippet" },
            { "<C-b>", function() require("luasnip").jump(1) end, mode = { "i", "s" }, desc = "Jump forward" },
            { "<C-z>", function() require("luasnip").jump(-1) end, mode = { "i", "s" }, desc = "Jump backward" },
        },
    },

    -- ============================================================
    -- TPOPE — classics that work perfectly in Neovim
    -- ============================================================
    { "tpope/vim-commentary", keys = { { "gc", mode = { "n", "v" } }, "gcc" } },
    { "tpope/vim-surround", event = "VeryLazy" },
    { "tpope/vim-repeat", event = "VeryLazy" },
    { "tpope/vim-unimpaired", event = "VeryLazy" },

    -- ============================================================
    -- AUTOPAIRS — replaces delimitMate, with better cmp integration
    --
    -- Quote behavior: pressing ", ', or ` ALWAYS inserts a pair, with no
    -- conditional skip. Rationale: the user's mental model is that quotes
    -- always come in pairs to keep the syntax balanced, regardless of whether
    -- the cursor sits inside or outside an existing string. This avoids the
    -- f-string editing nuisance ("foo 1|2 bar" → typing " should give
    -- "foo 1""|2 bar", not skip into "foo 1"|2 bar").
    --
    -- Brackets and parens keep their default smart behavior.
    -- ============================================================
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")

            npairs.setup({
                check_ts = true,
            })

            -- Remove default rules for quote-like characters and replace them
            -- with unconditional pair-inserting rules. The third Rule argument
            -- limits the rule to specific filetypes; empty list means "all".
            for _, q in ipairs({ '"', "'", "`" }) do
                npairs.remove_rule(q)
                npairs.add_rule(Rule(q, q):with_pair(function() return true end))
            end

            -- Integrate with nvim-cmp: auto-insert parens when confirming function items
            local ok, cmp = pcall(require, "cmp")
            if ok then
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },

    -- ============================================================
    -- INDENT GUIDES — subtle vertical guides (useful in Python)
    -- ============================================================
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope = { enabled = false },  -- scope highlighting is noisy; keep it off
            })
        end,
    },

}
