vim.g.mapleader = ' '
vim.keymap.set('n', '<Space>', '<Nop>', { silent = true })
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Explorer" })
vim.keymap.set("n", "<leader>o", function()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd.wincmd "p"
  else
    vim.cmd.Neotree "focus"
  end
end, { desc = "Toggle Explorer Focus" })

if vim.loader then
  vim.loader.enable()
end

-- start prelude
local dpp_src = vim.fn.expand("$HOME/.cache/dpp/repos/github/Shougo/dpp.vim")
vim.opt.runtimepath:prepend(dpp_src)

local dpp = require("dpp")
-- end prelude

local dppBase = vim.fn.expand("~/.cache/dpp")
local dpp_config = vim.fn.expand("~/.config/nvim/dpp.ts")
local denops_src = vim.fn.expand("~/.cache/dpp/repos/github/vim-denops/denops.vim")
local ext_toml = vim.fn.expand("~/.cache/dpp/repos/github/Shougo/dpp-ext-toml")
local ext_lazy = vim.fn.expand("~/.cache/dpp/repos/github/Shougo/dpp-ext-lazy")
local ext_installer = vim.fn.expand("~/.cache/dpp/repos/github/Shougo/dpp-ext-installer")
local ext_git = vim.fn.expand("~/.cache/dpp/repos/github/Shougo/dpp-protocol-git")

vim.opt.runtimepath:append(denops_src)
vim.opt.runtimepath:append(ext_toml)
vim.opt.runtimepath:append(ext_lazy)
vim.opt.runtimepath:append(ext_installer)
vim.opt.runtimepath:append(ext_git)

print("dpp.load_state returned: " .. tostring(dpp.load_state(dppBase)))

if dpp.load_state(dppBase) then
  vim.api.nvim_create_autocmd("User", {
    pattern = "DenopsReady",
    callback = function()
      vim.notify("dpp load_state() is failed")
      dpp.make_state(dppBase, dpp_config)
    end,
  })
end


vim.api.nvim_create_autocmd("User", {
  pattern = "Dpp:makeStatePost",
  callback = function()
    vim.notify("dpp make_state() is done")
  end,
})

---------------------------------------------------------


vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.api.nvim_create_user_command("DppMakestate", function(val)
  dpp.make_state(dppBase, dpp_config)
end, { nargs = 0 })


vim.opt.laststatus = 3
vim.opt.cursorline = true

vim.cmd("set completeopt+=noinsert")

vim.opt.virtualedit = "none"

vim.opt.expandtab = true
