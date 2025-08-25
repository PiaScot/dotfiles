return {
  "stevearc/conform.nvim",
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
  },
  config = function()
    local conform = require("conform")

    local function get_formatter()
      if vim.fs.find({ "deno.json", "deno.jsonc" }, { upward = true, stop = vim.loop.os_homedir() })[1] then
        return { "deno_fmt" }
      end
      if vim.fs.find({
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.json5",
            ".prettierrc.js",
            ".prettierrc.cjs",
            "prettier.config.js",
            "prettier.config.cjs",
            ".prettierrc.toml",
          }, { upward = true, stop = vim.loop.os_homedir() })[1] then
        return { "prettierd" }
      end
      if vim.fs.find({ "biome.json" }, { upward = true, stop = vim.loop.os_homedir() })[1] then
        return { "biome" }
      end
      -- Default to biome for single files
      return { "biome" }
    end

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofumpt", "goimports" },
        json = { "jq" },
        html = { "prettierd" },
        python = { "ruff " },
        svelte = get_formatter,
        javascript = get_formatter,
        typescript = get_formatter,
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = function(bufnr)
        -- local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
        -- if filetype == "javascript" or filetype == "typescript" or filetype == "svelte" then
        --   local eslint_config_found = vim.fs.find({
        --     ".eslintrc",
        --     ".eslintrc.js",
        --     ".eslintrc.cjs",
        --     ".eslintrc.yaml",
        --     ".eslintrc.yml",
        --     ".eslintrc.json",
        --     "eslint.config.js",
        --   }, { upward = true, stop = vim.loop.os_homedir() })[1]
        --
        --   if eslint_config_found then
        --     vim.cmd("silent !eslint --fix " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(bufnr)))
        --     vim.wait(100, function() end)
        --   end
        -- end

        -- 2. Run conform format
        conform.format({ bufnr = bufnr, lsp_format = "fallback" })
      end,
    })
  end,
}
