local common = require('config.lsp.common')

local M = {}

local function go_on_attach(client, bufnr)
  -- 共通設定を適用
  common.on_attach(client, bufnr)

  if client.name == "gopls" then
    -- 保存時にimportを整理とフォーマット（該当バッファのみ）
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr, -- patternを削除してbufferのみ使用
      callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
        for cid, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
          end
        end
        vim.lsp.buf.format({ async = false })
      end
    })

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<leader>go', ':GoRun<CR>', bufopts)
    vim.keymap.set('n', '<leader>gt', ':GoTest<CR>', bufopts)
  end
end

M.setup = function(lspconfig)
  lspconfig.gopls.setup {
    on_attach = go_on_attach,
    capabilities = common.capabilities,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        -- 基本設定のみ
        experimentalPostfixCompletions = true,
        staticcheck = true,

        -- 重要なアナライザーのみ明示的に有効化
        analyses = {
          shadow = true,
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },

        -- インレイヒント
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },

        -- 補完設定
        completeUnimported = true,
        usePlaceholders = true,
        matcher = "Fuzzy",

        -- その他
        semanticTokens = true,
        vulncheck = "Imports",
      },
    },
  }
end

return M
