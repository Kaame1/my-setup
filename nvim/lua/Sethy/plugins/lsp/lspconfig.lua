return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- Возможности для автодополнения
        local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

        -- Функция при подключении LSP к буферу
        local function on_attach(_, bufnr)
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            map("n", "gd", vim.lsp.buf.definition, "Перейти к определению")
            map("n", "gD", vim.lsp.buf.declaration, "Перейти к объявлению")
            map("n", "gi", vim.lsp.buf.implementation, "Имплементации")
            map("n", "gr", vim.lsp.buf.references, "Ссылки")
            map("n", "K", vim.lsp.buf.hover, "Подсказка")
            map("n", "<leader>rn", vim.lsp.buf.rename, "Переименовать")
            map("n", "<leader>ca", vim.lsp.buf.code_action, "Действие кода")
            map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Форматировать")
        end

        -- 📦 Настройка серверов
        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                        telemetry = { enable = false },
                    },
                },
            },
            bashls = {},
            pyright = {},
            clangd = {
                cmd = { "clangd", "--background-index", "--clang-tidy" },
            },
        }

        -- 🧠 Новый API для Neovim 0.11+
        for name, config in pairs(servers) do
            config.capabilities = capabilities
            config.on_attach = on_attach
            vim.lsp.config(name, config)
            vim.lsp.enable(name)
        end

        vim.notify("✅ LSP configured successfully (lua, bash, python, c/c++)", vim.log.levels.INFO)
    end,
}

