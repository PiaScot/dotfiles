return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local nls = require("null-ls")

        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        nls.setup({
            on_attach = function(client, bufnr)
                client.server_capabilities.document_formatting = false
                client.server_capabilities.document_range_formatting = false
                -- client.offset_encodings = "utf-32"
                -- client.offset_encoding = "utf-8"
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false })
                            -- vim.lsp.buf.formatting_sync()
                        end,
                    })
                end
            end,
            sources = {
                -- nls.builtins.diagnostics.ruff,
                -- nls.builtins.diagnostics.shellcheck,
                nls.builtins.diagnostics.golangci_lint,

                -- nls.builtins.formatting.isort,
                nls.builtins.formatting.shfmt,
                nls.builtins.formatting.clang_format,
                -- nls.builtins.code_actions.gitsigns,
                nls.builtins.formatting.gofmt,
                nls.builtins.formatting.gofumpt,
                nls.builtins.formatting.goimports,

                -- nls.builtins.formatting.ruff,

                -- nls.builtins.formatting.golines,
                nls.builtins.formatting.stylua,
            },
        })
    end,
}
