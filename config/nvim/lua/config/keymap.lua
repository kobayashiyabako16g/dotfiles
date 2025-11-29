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

-- ###########
-- telescope
-- ###########
map('n', '<Leader>ff', "<cmd>Telescope find_files<CR>", { noremap = true, silent = true })
map('n', '<Leader>fg', "<cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
map('n', '<Leader>fb', "<cmd>Telescope buffers<CR>", { noremap = true, silent = true })
map('n', '<Leader>fh', "<cmd>Telescope help_tags<CR>", { noremap = true, silent = true })




-- ###########
-- toggleterm
-- ###########
local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  float_opts = {
    border = "rounded",
  },
})

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

local map = vim.keymap.set
-- ノーマルモードに戻る
map("t", "<esc>", [[<C-\><C-n>]])
map("t", "jj", [[<C-\><C-n>]])

-- terminal 内でのウィンドウ移動
map("t", "<C-h>", [[<C-\><C-n><C-w>h]])
map("t", "<C-j>", [[<C-\><C-n><C-w>j]])
map("t", "<C-k>", [[<C-\><C-n><C-w>k]])
map("t", "<C-l>", [[<C-\><C-n><C-w>l]])

-- lazygit
map("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { silent = true, noremap = true })

-- terminal 1〜3
map("n", "<leader>1", "<cmd>1ToggleTerm<CR>")
map("n", "<leader>2", "<cmd>2ToggleTerm<CR>")
map("n", "<leader>3", "<cmd>3ToggleTerm<CR>")

-- 分割方向切替
map("n", "<leader>th", function()
  require("toggleterm").toggle(0, 15, vim.loop.cwd(), "horizontal")
end)

map("n", "<leader>tv", function()
  require("toggleterm").toggle(0, 80, vim.loop.cwd(), "vertical")
end)

map("n", "<leader>tf", function()
  require("toggleterm").toggle(0, nil, vim.loop.cwd(), "float")
end)
