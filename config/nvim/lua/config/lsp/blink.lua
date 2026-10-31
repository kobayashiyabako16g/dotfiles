require('blink.cmp').setup({
  -- <CR> で確定, <C-Space> で表示, <C-e> で中断, <C-b>/<C-f> でドキュメントスクロール
  keymap = { preset = 'enter' },
  completion = {
    menu = { border = 'rounded' },
    documentation = { auto_show = true, window = { border = 'rounded' } },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = { implementation = 'rust' },
})
