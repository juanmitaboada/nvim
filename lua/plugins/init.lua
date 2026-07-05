-- ~/.config/nvim/lua/plugins/init.lua
--
-- Master list. Each import loads a file from lua/plugins/*.lua
-- lazy.nvim supports this pattern of splitting plugin specs across files.

return {
    { import = "plugins.lsp" },
    { import = "plugins.editor" },
    { import = "plugins.coding" },
    { import = "plugins.ai" },
}
