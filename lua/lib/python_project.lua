-- ~/.config/nvim/lua/lib/python_project.lua
--
-- Shared helpers for Python project detection in a monorepo layout.
--
-- This module exposes two functions used by multiple callers:
--   1. find_project_bin(tool)
--        Resolve a tool's executable by walking up from the current buffer's
--        directory to find a virtualenv (env/.venv/venv) that contains it.
--        Falls back to Mason's install path, then to the bare name.
--
--   2. find_python_project_root(opts)
--        Walk up from the current buffer's directory looking for the root of
--        a Python project that opts into the given tools (mypy, pylint, ...).
--        Returns the directory path, or nil if no match is found.
--
-- Used by:
--   - plugins/lsp.lua  (pylint via nvim-lint and ruff/black via conform)
--   - commands/mypy.lua (on-demand :Mypy command)

local M = {}

-- ============================================================
-- Tool detection rules
--
-- For each tool we declare:
--   - legacy_files: filenames in the directory that anchor the root
--     immediately (e.g. .pylintrc, mypy.ini). One match → done.
--   - pyproject_section: a Lua pattern that, if matched against any line of
--     pyproject.toml, anchors the root. Empty string → ignore pyproject.toml.
--
-- The patterns are intentionally permissive (e.g. "^%[tool%.pylint")
-- to match both legacy section names like [tool.pylint.MASTER] and modern
-- ones like [tool.pylint.main].
-- ============================================================
local TOOL_RULES = {
    pylint = {
        legacy_files = { ".pylintrc" },
        pyproject_section = "^%[tool%.pylint",
    },
    mypy = {
        legacy_files = { "mypy.ini", ".mypy.ini" },
        pyproject_section = "^%[tool%.mypy",
    },
    ruff = {
        legacy_files = { "ruff.toml", ".ruff.toml" },
        pyproject_section = "^%[tool%.ruff",
    },
    pytest = {
        legacy_files = { "pytest.ini" },
        pyproject_section = "^%[tool%.pytest",
    },
}

-- ============================================================
-- find_project_bin(tool)
-- ============================================================
function M.find_project_bin(tool)
    -- Start from the current buffer's directory, or cwd if the buffer has no file
    local start = vim.fn.expand("%:p:h")
    if start == "" then
        start = vim.fn.getcwd()
    end

    -- Walk up the directory tree looking for a venv with the tool installed
    local venv_names = { "env", ".venv", "venv" }
    local dir = start
    while dir ~= "/" and dir ~= "" do
        for _, venv in ipairs(venv_names) do
            local candidate = dir .. "/" .. venv .. "/bin/" .. tool
            if vim.fn.executable(candidate) == 1 then
                return candidate
            end
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break  -- reached filesystem root
        end
        dir = parent
    end

    -- Fallback: Mason-installed binary
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/" .. tool
    if vim.fn.executable(mason_bin) == 1 then
        return mason_bin
    end

    -- Last resort: bare name, let $PATH resolve it
    return tool
end

-- ============================================================
-- find_python_project_root(opts)
--
-- opts.tools: list of tool names from TOOL_RULES to check for
--             (e.g. { "pylint" } or { "mypy", "pylint" }).
--
-- Returns the directory path of the first ancestor that opts into ANY of
-- the requested tools, or nil if no match is found.
--
-- "Opting in" means:
--   - The directory contains one of the legacy files for that tool, OR
--   - The directory contains a pyproject.toml with the tool's [tool.X*]
--     section present.
-- ============================================================
function M.find_python_project_root(opts)
    opts = opts or {}
    local tools = opts.tools or {}
    if #tools == 0 then
        return nil
    end

    -- Build the set of legacy filenames and pyproject section patterns we
    -- care about, from the requested tools only.
    local legacy_files = {}
    local pyproject_patterns = {}
    for _, tool in ipairs(tools) do
        local rule = TOOL_RULES[tool]
        if rule then
            for _, fname in ipairs(rule.legacy_files) do
                table.insert(legacy_files, fname)
            end
            if rule.pyproject_section ~= "" then
                table.insert(pyproject_patterns, rule.pyproject_section)
            end
        end
    end

    local start = vim.fn.expand("%:p:h")
    if start == "" then
        start = vim.fn.getcwd()
    end

    local dir = start
    while dir ~= "/" and dir ~= "" do
        -- 1. Legacy config files anchor the root immediately
        for _, fname in ipairs(legacy_files) do
            if vim.fn.filereadable(dir .. "/" .. fname) == 1 then
                return dir
            end
        end

        -- 2. pyproject.toml: only counts if it contains a matching [tool.X*] section
        if #pyproject_patterns > 0 then
            local pyproject = dir .. "/pyproject.toml"
            if vim.fn.filereadable(pyproject) == 1 then
                local ok, lines = pcall(vim.fn.readfile, pyproject)
                if ok then
                    for _, line in ipairs(lines) do
                        for _, pattern in ipairs(pyproject_patterns) do
                            if line:match(pattern) then
                                return dir
                            end
                        end
                    end
                end
            end
        end

        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break  -- reached filesystem root
        end
        dir = parent
    end

    return nil
end

return M
