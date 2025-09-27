local M = {}

M.setup = function()
  -- ホバーウィンドウのボーダー設定
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = "rounded",
    }
  )

  -- シグネチャヘルプのボーダー設定
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
      border = "rounded",
    }
  )

  -- 進行状況の表示設定
  vim.lsp.handlers["$/progress"] = vim.lsp.with(
    vim.lsp.handlers["$/progress"], {
      -- プログレス表示をカスタマイズする場合
    }
  )
end

return M
