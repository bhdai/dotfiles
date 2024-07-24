return {
    {
        "tiagovla/tokyodark.nvim",
        lazy = true,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyodark]])
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false, -- set it to false to make sure it load during startup if it is your main theme
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
}
