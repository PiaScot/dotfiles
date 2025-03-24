return {
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      local builtin = require("telescope.builtin")
      require("telescope").load_extension("frecency")
      vim.keymap.set("n", "<leader>s", builtin.find_files, {})
      vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
      vim.keymap.set("n", "<leader>r", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>b", builtin.buffers, {})
      vim.keymap.set("n", "<leader>f", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>")

      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false,
            },
          },
        },
      })
    end,
  },


}
