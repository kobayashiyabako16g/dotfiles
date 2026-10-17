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

vim.opt.expandtab = true

-- color
require("config/color")

-- plugins
require("config/bufferline")
require("config/toggleTerm")
require("config/whichkey")
require("config/lazy")

-- keymap
require("config/keymap")

-- lsp
require('config/lsp')
