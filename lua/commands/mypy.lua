-- ~/.config/nvim/lua/commands/mypy.lua
--
-- On-demand :Mypy command and <leader>m keymap to run mypy against the
-- current Python buffer, with results sent to the quickfix list.
--
-- Design:
--   - Async (vim.fn.jobstart), does not block the editor.
--   - Resolves mypy binary via the project's virtualenv (lib.python_project).
--   - cwd is the subproject root (the directory with pyproject.toml that has
--     [tool.mypy], or with a legacy mypy.ini). If no subproject is detected,
--     falls back to the current working directory — degrading gracefully but
--     still useful.
--   - Output is parsed to quickfix entries with absolute paths so :cn / :cp
--     navigation works regardless of where the editor was launched from.
--
-- Why not nvim-lint? mypy is too slow with mypy_django_plugin to run on every
-- save. On-demand is the right model for it.
--
-- This module is loaded explicitly from init.lua (the root one, not the plugins
-- one) with `require("commands.mypy")`. Lazy.nvim does not scan this directory.

local proj = require("lib.python_project")

-- ============================================================
-- Parse one line of mypy output into a quickfix entry, or return nil if the
-- line is not a diagnostic (e.g. summary lines, blank lines).
--
-- Two formats are accepted:
--   path/file.py:42:10: error: message  [code]   (with column)
--   path/file.py:42: error: message  [code]      (without column)
--
-- mypy emits paths relative to cwd; the caller resolves them to absolute
-- paths so quickfix navigation always works.
-- ============================================================
local function parse_mypy_line(line, cwd)
    -- Try the "with column" form first, then fall back to "without column".
    local fname, lnum, col, level, msg =
        line:match("^([^:]+):(%d+):(%d+):%s+(%a+):%s+(.+)$")
    if not fname then
        fname, lnum, level, msg = line:match("^([^:]+):(%d+):%s+(%a+):%s+(.+)$")
        col = "0"
    end
    if not fname then
        return nil
    end

    -- Resolve to absolute path so quickfix navigates correctly.
    local abs = fname
    if not fname:match("^/") then
        abs = cwd .. "/" .. fname
    end

    -- Map mypy severity labels to quickfix type codes.
    -- mypy emits: error, note, warning.
    local qf_type = "E"
    if level == "note" then
        qf_type = "I"   -- info
    elseif level == "warning" then
        qf_type = "W"
    end

    return {
        filename = abs,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = msg,
        type = qf_type,
    }
end

-- ============================================================
-- Run mypy asynchronously against the current buffer.
-- ============================================================
local function run_mypy()
    if vim.bo.filetype ~= "python" then
        vim.notify("Mypy: not a Python buffer", vim.log.levels.WARN)
        return
    end

    local file = vim.fn.expand("%:p")
    if file == "" then
        vim.notify("Mypy: buffer has no file", vim.log.levels.WARN)
        return
    end

    -- Resolve binary and project root via the shared helpers.
    local mypy_bin = proj.find_project_bin("mypy")
    local cwd = proj.find_python_project_root({ tools = { "mypy" } })
                or vim.fn.getcwd()

    -- Translate the file path to be relative to cwd, so mypy reports paths
    -- that match the project layout (and resolve cleanly back to absolute).
    local rel_file = file
    if file:sub(1, #cwd + 1) == cwd .. "/" then
        rel_file = file:sub(#cwd + 2)
    end

    vim.notify("Mypy: running on " .. rel_file .. " …", vim.log.levels.INFO)

    local output_lines = {}

    vim.fn.jobstart({ mypy_bin, rel_file }, {
        cwd = cwd,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, code, _)
            -- Parse all collected lines into quickfix entries.
            local qf_entries = {}
            for _, line in ipairs(output_lines) do
                local entry = parse_mypy_line(line, cwd)
                if entry then
                    table.insert(qf_entries, entry)
                end
            end

            if #qf_entries == 0 then
                if code == 0 then
                    vim.notify("Mypy: clean ✓", vim.log.levels.INFO)
                else
                    -- Non-zero exit with no parsed entries usually means an
                    -- internal mypy error. Show the raw output to help debug.
                    local raw = table.concat(output_lines, "\n")
                    vim.notify("Mypy: failed (exit " .. code .. ")\n" .. raw,
                        vim.log.levels.ERROR)
                end
                -- Clear any previous mypy quickfix list.
                vim.fn.setqflist({}, "r", { title = "Mypy", items = {} })
                return
            end

            -- Populate the quickfix list and open it for navigation.
            vim.fn.setqflist({}, "r", {
                title = "Mypy: " .. rel_file,
                items = qf_entries,
            })
            vim.cmd("copen")
            vim.notify(
                "Mypy: " .. #qf_entries .. " issue(s)",
                vim.log.levels.WARN
            )
        end,
    })
end

-- ============================================================
-- Register the command and keymap.
-- ============================================================
vim.api.nvim_create_user_command("Mypy", run_mypy, {
    desc = "Run mypy on the current Python buffer (results to quickfix)",
})

vim.keymap.set("n", "<leader>m", run_mypy, {
    silent = true,
    desc = "Mypy: check current buffer",
})
