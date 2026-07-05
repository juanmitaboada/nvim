-- ~/.config/nvim/lua/plugins/lsp.lua
--
-- This file replaces YCM + ALE + vim-lsp + black + isort + clang-format + cppcheck.
-- Organized in five sections:
--   1. Mason  (installer for LSPs / linters / formatters)
--   2. LSP    (vim.lsp.config + basedpyright + clangd + ruff + others)
--   3. CMP    (completion)
--   4. Format (conform.nvim: ruff, clang-format, shfmt)
--   5. Lint   (nvim-lint: pylint when project opts in, shellcheck, yamllint)

-- Shared Python project helpers (find_project_bin and find_python_project_root)
-- live in lua/lib/python_project.lua so the on-demand :Mypy command and other
-- callers can reuse the same detection logic.
local proj = require("lib.python_project")
local find_project_bin = proj.find_project_bin
local find_python_project_root = proj.find_python_project_root

return {

    -- ============================================================
    -- 1. MASON — external tooling installer
    -- ============================================================
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({
                ui = { border = "rounded" },
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                -- LSP servers we always want installed
                ensure_installed = {
                    "basedpyright",    -- Python semantic analysis
                    "ruff",            -- Python lint + format (via LSP)
                    "clangd",          -- C/C++
                    "rust_analyzer",   -- Rust
                    "zls",             -- Zig
                    "bashls",          -- Bash
                    "yamlls",          -- YAML
                    "lua_ls",          -- Lua (to edit this config itself)
                    "marksman",        -- Markdown
                    "dockerls",        -- Dockerfile
                },
                automatic_installation = true,
            })
        end,
    },

    -- Install external formatters and linters via Mason
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "black",            -- Python formatter (kept for legacy projects)
                    "mypy",             -- Python type checker (used by :Mypy)
                    "shfmt",            -- Shell formatter
                    "clang-format",     -- C/C++ formatter
                    "pylint",           -- Python linter (only triggered per project)
                    "shellcheck",       -- Shell linter
                    "yamllint",         -- YAML linter
                    "hadolint",         -- Dockerfile linter (not in apt)
                },
            })
        end,
    },

    -- ============================================================
    -- 2. LSP — server configuration via the Nvim 0.11+ API
    --
    -- We load this eagerly (lazy = false) so vim.lsp.config(...) runs at
    -- startup, before any buffer triggers an LSP attach. Loading lazily
    -- on BufReadPre caused the server configs to be registered too late.
    -- ============================================================
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",  -- expose cmp capabilities to each LSP
        },
        lazy = false,
        priority = 100,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Buffer-local LSP keymaps, bound when an LSP attaches.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LspAttachKeymaps", { clear = true }),
                callback = function(event)
                    local bufnr = event.buf
                    local bufmap = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end

                    -- Navigation (complements the global <CR> = definition mapping)
                    bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                    bufmap("n", "gr", ":Telescope lsp_references<CR>", "References")
                    bufmap("n", "gi", vim.lsp.buf.implementation, "Implementation")
                    bufmap("n", "K", vim.lsp.buf.hover, "Hover docs")
                    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
                    bufmap("n", "<leader>ws", ":Telescope lsp_dynamic_workspace_symbols<CR>", "Workspace symbols")

                    -- Neovim 0.11 ships global gr* LSP maps (grn/gra/grr/gri/grt)
                    -- that overlap with our gr -> references, forcing a timeoutlen
                    -- wait on gr and cluttering which-key. We already provide our
                    -- own scheme (gr, gi, <leader>rn, <leader>ca), so drop them.
                    for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
                        pcall(vim.keymap.del, "n", lhs)
                    end
                end,
            })

            -- Default capabilities applied to every server.
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- Python: basedpyright (semantic analysis)
            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = "standard",   -- off | basic | standard | strict
                            autoImportCompletions = true,
                            diagnosticMode = "openFilesOnly",  -- don't scan the whole project on open
                        },
                    },
                },
            })

            -- Python: ruff LSP (ultra-fast lint + fixes).
            -- Ruff honors pyproject.toml or ruff.toml in the project root,
            -- which is the correct place for per-project configuration.
            vim.lsp.config("ruff", {
                -- Disable ruff's hover so basedpyright handles it.
                on_attach = function(client, _)
                    client.server_capabilities.hoverProvider = false
                end,
            })

            -- C/C++: clangd (replaces ccls + vim-clang)
            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                },
            })

            -- YAML (docker-compose, CI, Ansible, etc.)
            vim.lsp.config("yamlls", {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/docker-compose"] = "docker-compose*.{yml,yaml}",
                            ["https://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
                        },
                    },
                },
            })

            -- Lua (so lua_ls stops complaining about the `vim` global in this config)
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Enable all configured servers. Servers with no explicit config
            -- (rust_analyzer, zls, bashls, marksman, dockerls) just use defaults.
            vim.lsp.enable({
                "basedpyright",
                "ruff",
                "clangd",
                "rust_analyzer",
                "zls",
                "bashls",
                "yamlls",
                "lua_ls",
                "marksman",
                "dockerls",
            })

            -- === Diagnostics UI (modern Nvim 0.11+ API) ===
            vim.diagnostic.config({
                virtual_text = { prefix = "●", spacing = 2 },
                underline = true,
                update_in_insert = false,   -- only lint on save / leaving insert mode, not while typing
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                -- Gutter signs: configured here instead of the legacy sign_define API
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "✘",
                        [vim.diagnostic.severity.WARN]  = "▲",
                        [vim.diagnostic.severity.HINT]  = "⚑",
                        [vim.diagnostic.severity.INFO]  = "»",
                    },
                },
            })

            -- === Auto-show diagnostic message in echo line on cursor hold ===
            -- After ~300ms of cursor inactivity (controlled by 'updatetime' in
            -- options.lua), if the cursor is on a line with a diagnostic, show
            -- the message in the echo line (bottom of the editor).
            --
            -- Design rationale: only CursorHold drives the echo, never
            -- CursorMoved. Emitting two consecutive `nvim_echo` calls (one to
            -- clear, one to print) triggers Neovim's hit-enter prompt to avoid
            -- losing messages. By using a single emit per CursorHold, we
            -- guarantee no hit-enter prompt ever appears.
            --
            -- Trade-off: when the cursor moves from a line with a diagnostic
            -- to a clean line, the previous message remains visible for up to
            -- ~300ms (until the next CursorHold fires and clears it).
            local severity_labels = {
                [vim.diagnostic.severity.ERROR] = { label = "ERROR", hl = "DiagnosticError" },
                [vim.diagnostic.severity.WARN]  = { label = "WARN",  hl = "DiagnosticWarn"  },
                [vim.diagnostic.severity.INFO]  = { label = "INFO",  hl = "DiagnosticInfo"  },
                [vim.diagnostic.severity.HINT]  = { label = "HINT",  hl = "DiagnosticHint"  },
            }

            -- Truncate a string to fit within `max_cols` display columns.
            -- Uses strdisplaywidth to handle wide / multibyte characters
            -- correctly, so the echoed line never wraps and never triggers
            -- the hit-enter prompt.
            local function truncate_to_columns(s, max_cols)
                if vim.fn.strdisplaywidth(s) <= max_cols then
                    return s
                end
                -- Remove characters from the end until it fits, leaving room for the ellipsis.
                local out = s
                while vim.fn.strdisplaywidth(out) > max_cols - 1 and #out > 0 do
                    out = out:sub(1, -2)
                end
                return out .. "…"
            end

            local function show_line_diagnostic_in_echo()
                local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1  -- 0-indexed
                local diags = vim.diagnostic.get(0, { lnum = lnum })

                if #diags == 0 then
                    -- No diagnostics on this line: emit a single empty echo.
                    -- A single empty message does not trigger hit-enter.
                    vim.api.nvim_echo({ { "" } }, false, {})
                    return
                end

                -- Pick the highest-severity diagnostic (lowest numeric severity = most important)
                table.sort(diags, function(a, b) return a.severity < b.severity end)
                local primary = diags[1]
                local sev = severity_labels[primary.severity] or { label = "?", hl = "Normal" }

                -- Build the message: [SEV] source: message  (+N more)
                local source = primary.source and (" " .. primary.source .. ":") or ""
                local extra = (#diags > 1) and ("  (+" .. (#diags - 1) .. " more)") or ""
                local single_line_msg = primary.message:gsub("\n", " "):gsub("%s+", " ")
                local full = string.format("[%s]%s %s%s", sev.label, source, single_line_msg, extra)

                -- Conservative max width: total columns minus ruler/showcmd area.
                -- Subtract enough margin that the message comfortably fits on
                -- one line even with extra UI chrome (cmdheight, signcolumn, etc.).
                local max_cols = math.max(20, vim.o.columns - 20)
                full = truncate_to_columns(full, max_cols)

                vim.api.nvim_echo({ { full, sev.hl } }, false, {})
            end

            vim.api.nvim_create_autocmd("CursorHold", {
                group = vim.api.nvim_create_augroup("DiagnosticEchoLine", { clear = true }),
                callback = show_line_diagnostic_in_echo,
            })
        end,
    },

    -- ============================================================
    -- 3. CMP — completion (replaces YouCompleteMe)
    --
    -- Tab is left free for Copilot (see plugins/ai.lua).
    -- Arrow keys navigate the completion menu when it's visible.
    -- When the menu is not visible, arrow keys move the cursor as usual
    -- (nvim-cmp's fallback mechanism handles the context switch).
    -- ============================================================
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",     -- source: LSP
            "hrsh7th/cmp-buffer",       -- source: current buffer
            "hrsh7th/cmp-path",         -- source: filesystem paths
            "saadparwaiz1/cmp_luasnip", -- source: luasnip
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),

                    -- Arrow keys navigate the completion menu when visible;
                    -- otherwise fall through to cursor movement (default behavior).
                    ["<Down>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<Up>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    -- Note: <Tab> is intentionally NOT mapped here.
                    -- It belongs to Copilot (see plugins/ai.lua).
                    -- Snippet expansion is triggered with <F2> (see LuaSnip keys).
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                }, {
                    { name = "buffer" },
                }),
                experimental = { ghost_text = false },  -- disabled to avoid visual clash with Copilot's ghost text
            })
        end,
    },

    -- ============================================================
    -- 4. FORMAT — conform.nvim (replaces standalone black / isort / clang-format)
    --
    -- Python is formatted by ruff: first `ruff_format` (style/length), then
    -- `ruff_organize_imports` (isort replacement). Both resolved via the
    -- project's virtualenv to respect per-project pinned versions.
    -- ============================================================
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    python = { "ruff_format", "ruff_organize_imports" },
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                    sh = { "shfmt" },
                    bash = { "shfmt" },
                    lua = { "stylua" },
                    json = { "jq" },
                    yaml = { "yamlfmt" },
                },
                format_on_save = {
                    timeout_ms = 2000,
                    lsp_fallback = true,  -- if no formatter is configured, fall back to the LSP
                },
                formatters = {
                    -- Use the project venv's ruff if available, falling back to Mason
                    ruff_format = {
                        command = function()
                            return find_project_bin("ruff")
                        end,
                    },
                    ruff_organize_imports = {
                        command = function()
                            return find_project_bin("ruff")
                        end,
                    },
                    -- clang-format: replicates the style block from the old .vimrc
                    clang_format = {
                        prepend_args = {
                            "--style={BasedOnStyle: Google, " ..
                            "BinPackArguments: false, BinPackParameters: false, " ..
                            "AccessModifierOffset: -4, AlignOperands: Align, " ..
                            "AlignArrayOfStructures: Left, " ..
                            "AllowShortIfStatementsOnASingleLine: true, " ..
                            "AllowShortBlocksOnASingleLine: Empty, " ..
                            "AlwaysBreakTemplateDeclarations: Yes, " ..
                            "IndentWidth: 4, PointerAlignment: Right, " ..
                            "QualifierAlignment: Left, RemoveBracesLLVM: false, " ..
                            "SeparateDefinitionBlocks: Always, Standard: Auto, " ..
                            "SpaceAfterCStyleCast: true, SpaceAfterLogicalNot: false, " ..
                            "SpaceAfterTemplateKeyword: true, " ..
                            "SpaceBeforeAssignmentOperators: true, " ..
                            "SpaceBeforeCpp11BracedList: true, " ..
                            "SpaceBeforeParens: ControlStatements, " ..
                            "SpaceBeforeRangeBasedForLoopColon: true, " ..
                            "SpaceBeforeSquareBrackets: false, " ..
                            "SpaceInEmptyBlock: false, SpacesBeforeTrailingComments: 2, " ..
                            "SpacesInAngles: Never, SpacesInContainerLiterals: false, " ..
                            "SpacesInCStyleCastParentheses: false}",
                        },
                    },
                },
            })

            -- To skip format-on-save for a single write: `:noautocmd w`
        end,
    },

    -- ============================================================
    -- 5. LINT — nvim-lint (non-LSP linters, on demand)
    --
    -- Pylint is resolved via find_project_bin so it uses the project's
    -- virtualenv (with pylint_django, pylint_pytest, pylint_pydantic, and
    -- all project dependencies visible). This replaces the old ale_finder.sh.
    --
    -- Pylint cwd is also pinned to the project root (the directory
    -- containing pyproject.toml with [tool.pylint*] or a legacy .pylintrc)
    -- so that imports resolve relative to that root. This matches the
    -- init-hook "sys.path.insert(0, '.')" pattern in monorepo subprojects
    -- where each subproject has its own pyproject.toml and venv.
    -- ============================================================
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost" },
        config = function()
            local lint = require("lint")

            -- Point pylint at the project-local binary.
            -- nvim-lint accepts a function for `cmd`, re-evaluated per call,
            -- so switching projects picks up the new venv automatically.
            lint.linters.pylint.cmd = function()
                return find_project_bin("pylint")
            end

            lint.linters_by_ft = {
                sh = { "shellcheck" },
                bash = { "shellcheck" },
                yaml = { "yamllint" },
                dockerfile = { "hadolint" },
                -- Python: pylint is added dynamically only when the project opts in
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                group = vim.api.nvim_create_augroup("NvimLintTrigger", { clear = true }),
                callback = function()
                    -- Python: add pylint only when the project opts in
                    if vim.bo.filetype == "python" then
                        local root = find_python_project_root({ tools = { "pylint" } })
                        if root then
                            -- Pin cwd so pylint resolves imports from the project root.
                            -- Set as a string just before try_lint, in case the user
                            -- jumps between subprojects within the same session.
                            lint.linters.pylint.cwd = root
                            lint.try_lint("pylint")
                        end
                    end
                    -- Other filetypes: standard lint
                    lint.try_lint()
                end,
            })
        end,
    },

}
