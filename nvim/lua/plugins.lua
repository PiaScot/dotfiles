local packer = nil
local function init()
    if packer == nil then
        packer = require 'packer'
        packer.init { disable_commands = true }
    end

    local use = packer.use
    packer.reset()

    -- basic tools and packer manager
    use 'wbthomason/packer.nvim'
    use 'lewis6991/impatient.nvim'

    -- frequency needed lua plugins
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    -- Async building & commands
    -- when using some test uncomment below line
    -- use { 'tpope/vim-dispatch', cmd = { 'Dispatch', 'Make', 'Focus', 'Start' } }

    -- ux improvement tools
    use 'antoinemadec/FixCursorHold.nvim'

    use {
        'nathom/filetype.nvim',
        config = function() vim.g.did_load_filetypes = 1
        end
    }

    -- cool exterior ui
    use 'kyazdani42/nvim-web-devicons'

    use 'rebelot/kanagawa.nvim'

    use {
        'akinsho/bufferline.nvim',
        requires = 'kyandani42/nvim-web-devicons',
        config = function() require'bufferline'.setup{}
        end
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyandani42/nvim-web-devicons', opt = true },
        config = function() require'lualine'.setup { options = { theme = 'horizon' } }
        end
    }

    -- comment
    use {
        'numToStr/Comment.nvim',
        config = function() require'Comment'.setup{}
        end
    }

    -- for highlight some ft eg.) markdown rmd, vimwiki
    use {
        'lukas-reineke/headlines.nvim',
        config = function()
            require('headlines').setup()
        end,
    }

    -- indent appearance
    use {
        'lukas-reineke/indent-blankline.nvim',
        config = [[require('config.indent_blankline')]],
    }

    -- memo
    use {
        {
            'nvim-orgmode/orgmode.nvim',
            -- config = [[require('config.orgmode')]]
        },
        'akinsho/org-bullets.nvim'
    }

    -- using table mode
    use 'junegunn/vim-easy-align'


    -- plugin help coding ux
    use 'folke/trouble.nvim'

    use 'kosayoda/nvim-lightbulb'

    use {
        'jose-elias-alvarez/null-ls.nvim',
        requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' }
    }

    use {
        'neovim/nvim-lspconfig',
        config = [[require('plugin.lsp')]]
    }

    use {
        'ms-jpq/coq_nvim',
        branch = 'coq',
        config = function() vim.g.coq_settings = { auto_start = true } end
    }

    use {
        "danymat/neogen",
        config = function()
            require('neogen').setup {}
        end,
        requires = "nvim-treesitter/nvim-treesitter",
        -- Uncomment next line if you want to follow only stable versions
        tag = "*"
    }
    use 'tversteeg/registers.nvim'

    -- for c or c++ refactoring
    use 'ThePrimeagen/refactoring.nvim'

    use 'edkolev/tmuxline.vim'

    use {
        'nvim-treesitter/nvim-treesitter',
        requires = {
            'nvim-treesitter/nvim-treesitter-refactor',
            'RRethy/nvim-treesitter-textsubjects',
        },
        run = ':TSUpdate',
    }
    use "tami5/sqlite.lua"

    use {
        {
            'nvim-telescope/telescope.nvim',
            requires = {
                'nvim-lua/popup.nvim',
                'nvim-lua/plenary.nvim',
                'telescope-frecency.nvim',
                'telescope-fzf-native.nvim',
                'nvim-telescope/telescope-ui-select.nvim',
            },
            wants = {
                'popup.nvim',
                'plenary.nvim',
                'telescope-frecency.nvim',
                'telescope-fzf-native.nvim',
            },
            setup = [[require('config.telescope_setup')]],
            config = [[require('config.telescope')]],
            cmd = 'Telescope',
            module = 'telescope',
        },
        {
            'nvim-telescope/telescope-frecency.nvim',
            after = 'telescope.nvim',
            requires = 'tami5/sqlite.lua',
        },
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            run = 'make',
        },
    }

end

local plugins = setmetatable({}, {
    __index = function(_, key)
        init()
        return packer[key]
    end,
})

return plugins
