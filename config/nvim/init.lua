if vim.loader then
  vim.loader.enable()
end

-- start prelude
local dppBase = vim.fn.expand("~/.cache/dpp")
local dpp_src = vim.fn.expand("~/.cache/dpp/repos/github.com/Shougo/dpp.vim")
vim.opt.runtimepath:prepend(dpp_src)

local dpp = require("dpp")
-- end prelude

local dpp_config = vim.fn.expand("~/.config/nvim/dpp.ts")
local denops_src = vim.fn.expand("~/.cache/dpp/repos/github.com/vim-denops/denops.vim")
local denops_hello = vim.fn.expand("~/.cache/dpp/repos/github.com/vim-denops/denops-helloworld.vim")
local ext_toml = vim.fn.expand("~/.cache/dpp/repos/github.com/Shougo/dpp-ext-toml")
local ext_lazy = vim.fn.expand("~/.cache/dpp/repos/github.com/Shougo/dpp-ext-lazy")
local ext_installer = vim.fn.expand("~/.cache/dpp/repos/github.com/Shougo/dpp-ext-installer")
local ext_local = vim.fn.expand("~/.cache/dpp/repos/github.com/Shougo/dpp-ext-local")
local ext_git = vim.fn.expand("~/.cache/dpp/repos/github.com/Shougo/dpp-protocol-git")

-- vim.g["denops#debug"] = 1
local ok = dpp.load_state(dppBase)
-- vim.notify("dpp.load_state returned: " .. tostring(ok))
vim.opt.runtimepath:prepend(denops_src)
vim.opt.runtimepath:prepend(denops_hello)
vim.opt.runtimepath:prepend(ext_installer)
vim.opt.runtimepath:prepend(ext_local)
vim.opt.runtimepath:prepend(ext_lazy)
vim.opt.runtimepath:prepend(ext_toml)
vim.opt.runtimepath:prepend(ext_git)

if ok then
  -- vim.notify("dpp.load_state() is successful")

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
    -- vim.notify("dpp make_state() is done")
  end,
})

-- ---------------------------------------------------------


vim.cmd("filetype indent plugin on")
vim.cmd("syntax on")

-- dpp commands
vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.api.nvim_create_user_command("DppMakestate", function(val)
  dpp.make_state(dppBase, dpp_config)
end, { nargs = 0 })
vim.api.nvim_create_user_command("DppClearstate", function(val)
  dpp.clear_state()
end, { nargs = 0 })
vim.api.nvim_create_user_command("DppGet", function(val)
  dpp.get()
end, { nargs = 0 })

vim.opt.laststatus = 3
vim.opt.cursorline = true

vim.cmd("set completeopt+=noinsert")

vim.opt.virtualedit = "none"
vim.cmd([[const mapleader = " "]])

vim.opt.expandtab = true

-- keymap
require("config/keymap")

-- lsp
require('config/lsp')
