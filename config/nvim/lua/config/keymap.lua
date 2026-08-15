-- ###########
-- Neo Tree configs
-- ###########
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
-- Tab navigation
map("n", "]t", "<cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "[t", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

-- ###########
-- bufferline (AstroNvim風タブ操作)
-- ###########
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick Buffer" })

-- フォーカス中のバッファだけを閉じる(ウィンドウ/nvim自体は閉じない)
local function close_buffer(force)
  local buf = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())

  if #listed > 1 then
    vim.cmd("bprevious")
  else
    vim.cmd("enew")
  end

  vim.cmd((force and "bdelete! " or "silent! bdelete ") .. buf)
end

map("n", "<leader>bd", function() close_buffer(false) end, { desc = "Close Buffer" })
map("n", "<leader>bD", function() close_buffer(true) end, { desc = "Force Close Buffer" })
map("n", "<leader>b<", "<cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Left" })
map("n", "<leader>b>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Right" })

-- ###########
-- telescope
-- ###########
map('n', '<Leader>ff', "<cmd>Telescope find_files<CR>", vim.tbl_extend("force", opts, { desc = "Find Files" }))
map('n', '<Leader>fg', "<cmd>Telescope live_grep<CR>", vim.tbl_extend("force", opts, { desc = "Live Grep" }))
map('n', '<Leader>fb', "<cmd>Telescope buffers<CR>", vim.tbl_extend("force", opts, { desc = "Find Buffers" }))
map('n', '<Leader>fh', "<cmd>Telescope help_tags<CR>", vim.tbl_extend("force", opts, { desc = "Help Tags" }))




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

-- ノーマルモードに戻る
map("t", "<esc>", [[<C-\><C-n>]])
map("t", "jj", [[<C-\><C-n>]])

-- terminal 内でのウィンドウ移動
map("t", "<C-h>", [[<C-\><C-n><C-w>h]])
map("t", "<C-j>", [[<C-\><C-n><C-w>j]])
map("t", "<C-k>", [[<C-\><C-n><C-w>k]])
map("t", "<C-l>", [[<C-\><C-n><C-w>l]])

-- lazygit
map("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { silent = true, noremap = true, desc = "Lazygit" })

-- terminal 1〜3
map("n", "<leader>1", "<cmd>1ToggleTerm<CR>", { desc = "Terminal 1" })
map("n", "<leader>2", "<cmd>2ToggleTerm<CR>", { desc = "Terminal 2" })
map("n", "<leader>3", "<cmd>3ToggleTerm<CR>", { desc = "Terminal 3" })

-- 分割方向切替
map("n", "<leader>th", function()
  require("toggleterm").toggle(0, 15, vim.loop.cwd(), "horizontal")
end, { desc = "Terminal Horizontal" })

map("n", "<leader>tv", function()
  require("toggleterm").toggle(0, 80, vim.loop.cwd(), "vertical")
end, { desc = "Terminal Vertical" })

map("n", "<leader>tf", function()
  require("toggleterm").toggle(0, nil, vim.loop.cwd(), "float")
end, { desc = "Terminal Float" })
