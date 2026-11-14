if vim.loader then
  vim.loader.enable()
end

vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

vim.opt.laststatus = 3
vim.opt.cursorline = true
vim.opt.mouse = "a"

vim.cmd("set completeopt+=noinsert")
vim.opt.clipboard = "unnamedplus"

vim.opt.virtualedit = "none"
vim.cmd([[const mapleader = " "]])

-- indent (vim-sleuth が検出できなかったときのデフォルト)
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.softtabstop = 4 -- Number of spaces tabs count for
vim.opt.tabstop = 4 -- Number of spaces in a tab
vim.opt.shiftround = true -- Round indent

-- ネストした nvim は外側に転送して終了するので最初に読み込む
require("config/flatten")

-- color
require("config/color")

-- plugins
require("config/bufferline")
require("config/gitsigns")
require("config/aerial")
require("config/toggleTerm")
require("config/whichkey")
require("config/lazy")

-- keymap
require("config/keymap")

-- lsp
require('config/lsp')
