local common = require('config/lsp/common')

-- PATHの設定
common.setup_tools_path()
common.setup_project_bin()

-- 診断設定を適用
common.setup_diagnostics()

-- lspconfigを取得
local lspconfig = require('lspconfig')

-- 各言語サーバーをセットアップ
local servers = {
  'gopls',
  'ts_ls',
}

for _, server in ipairs(servers) do
  local server_config = require('config.lsp.servers.' .. server)
  server_config.setup(lspconfig)
end

vim.lsp.config('*', {
  capabilities = common.capabilities,
  handlers = {
    -- ホバーウィンドウのボーダー設定
    ['textDocument/hover'] = function(err, result, ctx, opts)
      opts = vim.tbl_extend('force', opts or {}, { border = 'rounded' })
      vim.lsp.handlers.hover(err, result, ctx, opts)
    end,
    -- シグネチャヘルプのボーダー設定
    ['textDocument/signatureHelp'] = function(err, result, ctx, opts)
      opts = vim.tbl_extend('force', opts or {}, { border = 'rounded' })
      vim.lsp.handlers.signature_help(err, result, ctx, opts)
    end,
  },
})

-- Treesitter設定
require('config/lsp/treesitter')

-- nvim-cmp設定
require("config/lsp/cmp")
