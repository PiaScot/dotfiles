return {
    "numToStr/Comment.nvim",
    config = function()
        local ft = require("Comment.ft")
        ft.set("sml", { "(*%s*)", "(*%s*)" })
        require("Comment").setup({})
    end,
}

