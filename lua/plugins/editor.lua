-- ~/.config/nvim/lua/plugins/editor.lua
--
-- Navigation and general UI tools:
-- Telescope, nvim-tree, aerial, lualine, gitsigns, fugitive, which-key.

return {

    -- ============================================================
    -- TELESCOPE — replaces CtrlP, Ack, BufExplorer
    -- ============================================================
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        cmd = "Telescope",
        keys = {
            "<C-p>", "<leader>ff", "<leader>fg", "<leader>fb", "<leader>fh", "<leader>fr",
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    prompt_prefix = " 🔍 ",
                    selection_caret = "➤ ",
                    path_display = { "smart" },
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                    file_ignore_patterns = {
                        "node_modules", "%.git/", "%.venv/", "env/", "__pycache__",
                        "%.pyc", "dist/", "build/", "%.o", "%.a",
                    },
                },
                pickers = {
                    find_files = { hidden = true },
                },
            })
            pcall(telescope.load_extension, "fzf")
        end,
    },

    -- ============================================================
    -- NVIM-TREE — replaces NERDTree (F4)
    -- ============================================================
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        keys = { "<F4>" },
        config = function()
            -- Disable netrw so it doesn't fight with nvim-tree
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
                view = { width = 35 },
                renderer = {
                    group_empty = true,
                    icons = { show = { file = true, folder = true, git = true } },
                },
                filters = {
                    dotfiles = false,  -- show dotfiles (switch to true if they feel noisy)
                    custom = { "^%.git$", "__pycache__", "%.pyc$" },
                },
                git = { enable = true, ignore = false },
                actions = { open_file = { quit_on_open = false } },
            })
        end,
    },

    -- ============================================================
    -- AERIAL — replaces Tagbar (F3)
    -- ============================================================
    {
        "stevearc/aerial.nvim",
        -- aerial's master branch requires Neovim >= 0.12 (nightly). On stable
        -- Neovim (0.11.x) master aborts setup and never creates :AerialToggle,
        -- so F3 fails with "Command not found". Pin to the compat branch.
        branch = "nvim-0.11",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        cmd = { "AerialToggle", "AerialOpen" },
        keys = { "<F3>" },
        config = function()
            require("aerial").setup({
                backends = { "lsp", "treesitter", "markdown" },
                layout = { default_direction = "right", width = 35 },
                filter_kind = false,  -- show every kind of symbol
                show_guides = true,
            })
        end,
    },

    -- ============================================================
    -- LUALINE — replaces vim-airline
    -- ============================================================
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = { left = "|", right = "|" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,     -- single statusline for the whole editor
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },  -- relative path
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                extensions = { "nvim-tree", "aerial", "fugitive", "quickfix" },
            })
        end,
    },

    -- ============================================================
    -- GITSIGNS — replaces gitgutter + signify (one plugin instead of two)
    -- ============================================================
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "│" },
                    change       = { text = "│" },
                    delete       = { text = "_" },
                    topdelete    = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked    = { text = "┆" },
                },
                current_line_blame = false,  -- toggle on demand with :Gitsigns toggle_current_line_blame
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local map = function(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                    end
                    -- Hunk navigation
                    map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                    map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
                    -- Hunk actions
                    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                end,
            })
        end,
    },

    -- ============================================================
    -- FUGITIVE — advanced git operations
    -- ============================================================
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gvdiffsplit" },
        keys = { "<leader>gs", "<leader>gb", "<leader>gd" },
    },

    -- ============================================================
    -- WHICH-KEY — shows available hotkeys when a prefix is pressed
    -- ============================================================
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                preset = "modern",
            })
        end,
    },

    -- Colorscheme is the builtin `unokai`, set in init.lua (needs Neovim 0.10+).

}
