local lspconfig = require("lspconfig")
local server_config = require("lspconfig.configs")

require("lazydev").setup()
local lspconfig = require("lspconfig")

-- Language server settings
local servers = {
  "clangd",
  "rust_analyzer",
  "pyright",
  "gopls",
  "lua_ls",
  "denols",
  "vimls",
  "tailwindcss",
  "marksman",
  "ruff",
  "dockerls",
}

-- Auto start language servers.
for _, name in ipairs(servers) do
  if name == "tailwindcss" then
    lspconfig.tailwindcss.setup({})
    -- lspconfig[name].setup({})
    lspconfig.tailwindcss.setup({
      init_options = {
        rootMarkers = {
          ".git/",
        },
      },
    })
  else
    lspconfig[name].setup({})
  end
end

-- lsp keymaps
vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
