require('catppuccin').setup({
  flavour = "mocha", -- latte / frappe / macchiato / mocha
  integrations = {
    treesitter = true,
    native_lsp = { enabled = true },
    nvimtree = true,
    telescope = true,
    cmp = true,
    gitsigns = true,
  },
})
vim.cmd.colorscheme("catppuccin-mocha")
