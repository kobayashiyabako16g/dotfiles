-- ターミナル内で nvim を開いたとき、ネストせず外側の nvim でファイルを開く
-- ネスト側の nvim はここで終了するので、他のプラグインより先に読み込む

-- rebuild 前でプラグインが無いときは何もしない
local ok, flatten = pcall(require, "flatten")
if not ok then
  return
end

-- ファイルを開く前にフォーカスしていた toggleterm
local saved_terminal

flatten.setup({
  window = {
    open = "alternate",
  },
  hooks = {
    -- `nvim -b` でも書き終わるまで呼び出し元を待たせる
    should_block = function(argv)
      return vim.tbl_contains(argv, "-b")
    end,
    pre_open = function()
      local term = require("toggleterm.terminal")
      saved_terminal = term.get(term.get_focused_id())
    end,
    post_open = function(opts)
      if opts.is_blocking and saved_terminal then
        -- git commit などは float ターミナルを閉じて編集する
        saved_terminal:close()
      else
        vim.api.nvim_set_current_win(opts.winnr)
      end

      -- コミットメッセージは保存したらバッファを閉じる
      if opts.filetype == "gitcommit" or opts.filetype == "gitrebase" then
        vim.api.nvim_create_autocmd("BufWritePost", {
          buffer = opts.bufnr,
          once = true,
          callback = vim.schedule_wrap(function()
            vim.api.nvim_buf_delete(opts.bufnr, {})
          end),
        })
      end
    end,
    -- 編集が終わったらターミナルを開き直す
    block_end = function()
      vim.schedule(function()
        if saved_terminal then
          saved_terminal:open()
          saved_terminal = nil
        end
      end)
    end,
  },
})
