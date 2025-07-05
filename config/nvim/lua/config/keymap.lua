local opts = { silent = true }
local cr = "<CR>"

local keymap = vim.keymap.set
local runCmd = function(map, cmd)
  keymap("n", map, cmd .. "<CR>", opts)
end

keymap("n", "<C-[><C-[>", ":noh<CR>")
keymap("n", "<C-u>", "<cmd>Ddu source<CR>")

keymap("n", "s", "<C-w>", opts)
keymap("n", "sl", "<c-w>l", opts)
keymap("n", "sh", "<c-w>h", opts)

keymap("i", "jj", "<ESC>", opts)

keymap("i", "<C-g>", "<C-[><C-[>")

keymap("n", "<c-p>", "{", opts)
keymap("n", "<c-n>", "}", opts)

-- keymap("n", "<C-f>", "<cmd>Sayonara<CR>", opts)
keymap("n", "<C-f>", "<cmd>close<CR>", opts)

keymap("n", "<M-x>", "")

-- for Emacs compativirity
keymap("n", "<C-g>", "<ESC>")

-- comfortable moation
vim.g.comfortable_motion_no_default_key_mappings = 1

keymap("n", "<C-k>", "<C-u>")
keymap("n", "<C-j>", "<C-d>")


vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function(opts)
    vim.api.nvim_buf_set_keymap(0, "n", "gd", "<C-]>", { silent = true })
  end,
})

vim.fn.getwininfo()

vim.fn.filter(vim.fn.getwininfo(), function(key, val)
  return val.quickfix
end)
vim.print()
