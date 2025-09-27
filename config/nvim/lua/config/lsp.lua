local common = require('config/lsp/common')

-- 診断設定を適用
common.setup_diagnostics()

-- lspconfigを取得
local lspconfig = require('lspconfig')

-- 各言語サーバーをセットアップ
local servers = {
  'gopls',
}

for _, server in ipairs(servers) do
  local server_config = require('config.lsp.servers.' .. server)
  server_config.setup(lspconfig)
end
