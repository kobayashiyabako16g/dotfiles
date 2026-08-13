local wk = require("which-key")

wk.setup({
  preset = "modern",
})

wk.add({
  { "<leader>f", group = "Find (Telescope)" },
  { "<leader>t", group = "Terminal" },
  { "<leader>w", group = "LSP Workspace" },
  { "<leader>g", group = "Git" },
})
