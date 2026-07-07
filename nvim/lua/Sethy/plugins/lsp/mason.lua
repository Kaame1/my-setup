return {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "neovim/nvim-lspconfig",
    },
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            automatic_installation = true,
            ensure_installed = {
                "lua_ls",
                "bashls",   -- bash language server
                "pyright",  -- python
                "clangd",   -- c / c++
                "html",
                "cssls",
                "tailwindcss",
                "angularls",
                "emmet_ls",
                "marksman",
            },
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier",
                "stylua",
                "isort",
                "pylint",
                "clangd",
                "bash-language-server",
                "pyright",
            },
            automatic_installation = true, -- опция при необходимости
        })
    end,
}

