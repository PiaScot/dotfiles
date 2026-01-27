return {
  "mfussenegger/nvim-lint",
  event = "BufWritePost",
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
  },
  config = function()
    vim.env.ESLINT_D_PPID = vim.fn.getpid()
    local lint = require("lint")
    lint.linters.golangcilint = {
      cmd = "golangci-lint",
      args = { "run", "--out-format", "line-number", "$FILENAME" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%n %m"),
    }

    local function get_linter(bufnr)
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      if buf_name == "" then
        return { "biome" }
      end

      local buf_dir = vim.fn.fnamemodify(buf_name, ":h")

      if vim.fs.find({
            ".eslintrc",
            ".islintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
            "eslint.config.js",
          }, { path = buf_dir, upward = true, stop = vim.loop.os_homedir() })[1] then
        return { "eslint_d" }
      end
      if vim.fs.find({ "biome.json" }, { path = buf_dir, upward = true, stop = vim.loop.os_homedir() })[1] then
        return { "biome" }
      end
      -- Default to biome for single files
      return { "biome" }
    end

    lint.linters_by_ft = {
      rust = { "clippy" },
      json = { "jsonlint" },
      go = { "golangcilint" },
      python = { "ruff" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function(args)
        local lint_module = package.loaded["lint"]
        if not lint_module or type(lint_module) ~= "table" or not lint_module.set_linters or not lint_module.try_lint then
          -- lint module not fully loaded or functions not available yet, skip
          return
        end

        local filetype = vim.api.nvim_buf_get_option(args.buf, "filetype")
        if filetype == "svelte" or filetype == "javascript" or filetype == "typescript" then
          lint_module.set_linters(args.buf, get_linter(args.buf))
        else
          lint_module.try_lint(args.buf)
        end
      end,
    })
  end,
}

