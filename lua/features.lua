-- lua/features.lua
-- Optional features, OFF by default. A machine opts in by creating a
-- git-ignored lua/local.lua that returns overrides. On a plain checkout
-- (servers, someone else's machine) Copilot and WakaTime are neither
-- installed nor started.
--
--     -- lua/local.lua
--     return { copilot = true, wakatime = true }

local defaults = {
    copilot = false, -- github/copilot.vim + CopilotChat.nvim
    wakatime = false, -- wakatime/vim-wakatime
}

local ok, overrides = pcall(require, "local")
if ok and type(overrides) == "table" then
    return vim.tbl_extend("force", defaults, overrides)
end
return defaults
