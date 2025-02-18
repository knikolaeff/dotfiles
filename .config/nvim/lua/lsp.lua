local lspconfig = require('lspconfig')

require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require('mason-lspconfig').setup({
    -- A list of servers to automatically install if they're not already installed
    ensure_installed = { "clangd", "lua_ls" },
})

lspconfig.clangd.setup{}
lspconfig.ts_ls.setup{}
lspconfig.lua_ls.setup{}
lspconfig.terraformls.setup{}
