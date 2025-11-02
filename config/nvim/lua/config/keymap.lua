--Neo Tree configs
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Neo-tree トグル
map("n", "<Leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Toggle Explorer" })

-- Neo-tree フォーカス切り替え
map("n", "<Leader>o", function()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd.wincmd "p"
  else
    vim.cmd.Neotree "focus"
  end
end, { desc = "Toggle Explorer Focus" })


-- telescope
map('n', '<Leader>ff', "<cmd>Telescope find_files<CR>", { noremap = true, silent = true })
map('n', '<Leader>fg', "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
map('n', '<Leader>fb', "<cmd>Telescope buffers<CR>", { noremap = true, silent = true })
map('n', '<Leader>fh', "<cmd>Telescope help_tags<CR>", { noremap = true, silent = true })
