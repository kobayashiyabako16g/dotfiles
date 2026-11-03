require("aerial").setup({
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = {
    default_direction = "prefer_right",
    min_width = 30,
  },
  attach_mode = "global",
  show_guides = true,
})
