local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { 'folke/which-key.nvim',        event = 'VeryLazy',    config = true },
    { "echasnovski/mini.icons",      version = false, },
    { "tpope/vim-surround" },
    { "windwp/nvim-autopairs",       event = "InsertEnter", config = true, },
    { 'norcalli/nvim-colorizer.lua', config = true },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = { scope = { enabled = false }, }
    },

    {
      "akinsho/toggleterm.nvim",
      version = "*",
      keys = {
        { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Open terminal" },
      },
      opts = {
        direction = "float",
      },
    },
    {
      'Bekaboo/dropbar.nvim',
      -- optional, but required for fuzzy finder support
      dependencies = {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
      },
      config = function()
        local dropbar_api = require('dropbar.api')
        vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
        vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
        vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
      end
    },

    {
      "numToStr/Comment.nvim",
      dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
      },
      config = function()
        require("ts_context_commentstring").setup({
          enable_autocmd = false,
        })
        require("Comment").setup({
          pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
      end,
    },
    {
      "phaazon/hop.nvim",
      branch = "v2",
      keys = {
        { "f", "<cmd>HopChar1<cr>", desc = "Hop mode with f-press with normal mode" },
      },
      opts = { keys = "etovxqpdygfblzhckisuran" },
    },
    { import = "plugins" },
  },
  change_detection = {
    notify = false,
  },
  ui = {
    size = { width = 0.7, height = 0.7 },
    border = "single",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "gzip",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "2html_plugin",
        "man",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "matchit",
        "matchparen",
      },
    },
  },
})
