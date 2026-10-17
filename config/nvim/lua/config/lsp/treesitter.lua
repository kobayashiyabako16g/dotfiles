require('nvim-treesitter').setup {}

-- パーサーは Nix (nix/home/neovim.nix) で管理

-- 構文ハイライト・インデントを有効化（パーサーが無い場合は無視）
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    if pcall(vim.treesitter.start) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- テキストオブジェクト設定
require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
}

local ts_select = require('nvim-treesitter-textobjects.select')
local ts_move = require('nvim-treesitter-textobjects.move')
local ts_swap = require('nvim-treesitter-textobjects.swap')

local function select_textobject(query)
  return function()
    ts_select.select_textobject(query, 'textobjects')
  end
end

-- 関数
vim.keymap.set({ 'x', 'o' }, 'af', select_textobject('@function.outer'))
vim.keymap.set({ 'x', 'o' }, 'if', select_textobject('@function.inner'))
-- クラス
vim.keymap.set({ 'x', 'o' }, 'ac', select_textobject('@class.outer'))
vim.keymap.set({ 'x', 'o' }, 'ic', select_textobject('@class.inner'))
-- 条件文
vim.keymap.set({ 'x', 'o' }, 'ai', select_textobject('@conditional.outer'))
vim.keymap.set({ 'x', 'o' }, 'ii', select_textobject('@conditional.inner'))
-- ループ
vim.keymap.set({ 'x', 'o' }, 'al', select_textobject('@loop.outer'))
vim.keymap.set({ 'x', 'o' }, 'il', select_textobject('@loop.inner'))
-- パラメータ/引数
vim.keymap.set({ 'x', 'o' }, 'aa', select_textobject('@parameter.outer'))
vim.keymap.set({ 'x', 'o' }, 'ia', select_textobject('@parameter.inner'))
-- コメント
vim.keymap.set({ 'x', 'o' }, 'a/', select_textobject('@comment.outer'))
vim.keymap.set({ 'x', 'o' }, 'i/', select_textobject('@comment.inner'))

-- テキストオブジェクト間の移動
vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
  ts_move.goto_next_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
  ts_move.goto_next_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
  ts_move.goto_next_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
  ts_move.goto_next_end('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
  ts_move.goto_previous_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
  ts_move.goto_previous_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
  ts_move.goto_previous_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
  ts_move.goto_previous_end('@class.outer', 'textobjects')
end)

-- スワップ（入れ替え）
vim.keymap.set('n', '<leader>a', function()
  ts_swap.swap_next('@parameter.inner')
end)
vim.keymap.set('n', '<leader>A', function()
  ts_swap.swap_previous('@parameter.inner')
end)

-- treesitter-context設定（現在のコンテキストを上部に表示）
require('treesitter-context').setup {
  enable = true,
  max_lines = 0, -- 0 = 無制限
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = nil,
}
