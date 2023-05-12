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
    {
        -- manipulating parentheses, brackets, quotes, etc.
        'kylechui/nvim-surround',
        event = "BufRead",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },
    {
        -- replace with register
        'gbprod/substitute.nvim',
        lazy = true,
        config = true
    },
    {
        -- easy motion
        'phaazon/hop.nvim',
        branch = 'v2', -- optional but strongly recommended
        lazy = true,
        config = function()
            require('hop').setup({
                jump_on_sole_occurrence = false,
            })
        end,
    },
    {
        -- macro manager
        'svermeulen/vim-macrobatics',
        dependencies = { 'tpope/vim-repeat' },
        event = "BufRead",
        init = function()
            vim.g.Mac_NamedMacrosDirectory = vim.fn.stdpath("config") .. "/macrobatics"
        end,
    },
    {
        -- fast insert mode exit
        'max397574/better-escape.nvim',
        event = "InsertEnter",
        config = function()
            require('better_escape').setup({
                keys = function()
                    return vim.api.nvim_win_get_cursor(0)[2] > 1 and '<esc>l' or '<esc>'
                end,
            })
        end,
    },
    {
        -- more text objects
        'wellle/targets.vim',
        event = "BufRead",
    },
    { -- show and remove trailing whitespaces
        'jdhao/whitespace.nvim',
        event = "BufRead",
    },
    { -- directory viewer
        'nvim-tree/nvim-tree.lua',
        init = function()
            -- disable netrw at the very start of your init.lua (strongly advised)
            -- reference: https://github.com/nvim-tree/nvim-tree.lua
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        lazy = true,
        config = true,
    },
    { -- show keymap
        -- TODO: edit defaults
        'folke/which-key.nvim',
        lazy = true,
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup()
        end,
    },
    { -- fancy tab line
        'akinsho/bufferline.nvim',
        version = 'v3.*',
        config = function()
            require('bufferline').setup({
                options = {
                    separator_style = 'thick',
                    show_close_icon = false
                },
            })
        end,
    },
    { -- indent guide
        "lukas-reineke/indent-blankline.nvim",
        event = "BufRead",
    },
})

local wk = require("which-key")

-- Editing
-- TODO: fix xx, dd, cc, ss
wk.register({
    x = { 'd', 'Cut' },
    xx = { 'dd', 'Cut line' },
    X = { 'D', 'Cut to end of line' },
    d = { '"_d', 'Delete' },
    dd = { '"_dd', 'Delete line' },
    D = { '"_D', 'Delete to end of line' },
    c = { '"_c', 'Change' },
    cc = { '"_cc', 'Change line' },
    C = { '"_C', 'Change to end of line' },
    s = { function() require('substitute').operator() end, 'Substitute' },
    ss = { function() require('substitute').line() end, 'Substitute line' }, -- nmapping '_' (start of line) breaks this
    S = { function() require('substitute').eol() end, 'Substitute to end of line' },
})

wk.register({
    x = { 'd', 'Cut' },
    d = { '"_d', 'Delete' },
    c = { '"_c', 'Change' },
    s = { function() require('substitute').operator() end, 'Substitute' },
}, {
    mode = { 'x' },
})

wk.register({
    ['<RightMouse>'] = { '<LeftMouse>.', 'Repeat' },
}, {
    noremap = false,
})

-- Movements
wk.register({
    H = { '^', 'Start of line' },
    L = { '$', 'End of line' },
}, {
    mode = { 'n', 'x', 'o' },
})

-- Hop motion
wk.register({
    ['^'] = {
        function()
            require('hop').hint_lines_skip_whitespace()
        end,
        'Hop line',
    },
    ['m'] = {
        function()
            require('hop').hint_words()
        end,
        'Hop word',
    },
    ['M'] = {
        function()
            require('hop').hint_words({
                hint_position = require 'hop.hint'.HintPosition.END,
            })
        end,
        'Hop end of word',
    },
}, {
    mode = { 'n', 'x', 'o' },
})

wk.register({
    ["<C-w>"] = {
        name = "+Windowing",
        t = {
            function()
                vim.cmd('tabnew')
            end,
            'Open new tab'
        },
        e = {
            function()
                vim.cmd('terminal')
            end,
            'Open terminal'
        },
        q = {
            function()
                vim.cmd('bdelete')
            end,
            'Close buffer'
        },
    },
})


vim.keymap.set(
'n', '(', function()
    vim.cmd('BufferLineCyclePrev')
end, { desc = 'Previous buffer' }
)

vim.keymap.set(
'n', ')', function()
    vim.cmd('BufferLineCycleNext')
end, { desc = 'Next buffer' }
)

-- UI related
wk.register({
    ['<leader>u'] = {
        name = '+Toggle UI',
        t = {
            function()
                vim.cmd("TroubleToggle")
            end,
            'Toggle trouble list',
        },
        d = {
            function()
                require("nvim-tree.api").tree.toggle()
            end,
            'Toggle directory viewer',
        },
        o = {
            function()
                vim.cmd("Lspsaga outline")
            end,
            'Toggle LSP outline',
        },
    },
    ['<leader>t'] = {
        name = '+ToggleTerm',
        t = {
            function()
                vim.cmd("ToggleTerm direction=tab")
            end,
            'ToggleTerm in new tab',
        },
        v = {
            function()
                vim.cmd("ToggleTerm direction=vertical size=40")
            end,
            'ToggleTerm in vertical split',
        },
        f = {
            function()
                vim.cmd("ToggleTerm direction=float")
            end,
            'ToggleTerm in floating window',
        },
    },
    ['<leader>f'] = {
        name = '+File',
        f = {
            function()
                require('telescope.builtin').find_files()
            end,
            'Find file',
        },
        g = {
            function()
                require('telescope.builtin').live_grep()
            end,
            'Find word',
        },
        b = {
            function()
                require('telescope.builtin').buffers()
            end,
            'Find buffer',
        },
        h = {
            function()
                require('telescope.builtin').help_tags()
            end,
            'Find help tag',
        },
        o = {
            function()
                require('telescope.builtin').oldfiles()
            end,
            'Recent files',
        },
        n = {
            function()
                require('startup').new_file()
            end,
            'New file',
        },
    },
})

-- Terminal mode maps
wk.register({
    ['<C-j><C-j>'] = {
        [[<C-\><C-n>]],
        "Fast exit"
    }
}, {
    mode = 't',
})

-- Insert mode maps
wk.register({
    ['<C-h>'] = { '<Left>', 'Left' },
    ['<C-j>'] = { '<Down>', 'Down' },
    ['<C-k>'] = { '<Up>', 'Up' },
    ['<C-l>'] = { '<Right>', 'Right' },
    ['<C-v>'] = { '<C-r>+', 'Paste' },
}, {
    mode = 'i',
})

-- Macro related
wk.register({
    q = {
        '<plug>(Mac_Play)',
        'Execute macro',
    },
    gq = {
        '<plug>(Mac_RecordNew)',
        'Record new macro',
    },
})

local opt = vim.opt

-- tab settings
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- side number settings
opt.number = true
opt.relativenumber = true

-- cursorline
opt.cursorline = true
-- opt.cursorcolumn = true

-- wrap settings
opt.breakindent = true
opt.linebreak = true
opt.showbreak = '↳'

-- smartcase for searching
opt.ignorecase = true
opt.smartcase = true

-- status line already has ruler and mode
opt.ruler = false
opt.showmode = false

-- split right and below
opt.splitright = true
opt.splitbelow = true

-- synchronize the unnamed register with the clipboard register
opt.clipboard:prepend('unnamedplus')

-- set default shell of built-in terminal
opt.shell = 'fish'
