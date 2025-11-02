local common = require('config.lsp.common')

local M = {}

function M.setup(lspconfig)
  lspconfig.ts_ls.setup({
    capabilities = common.capabilities,
    root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json', '.git'),
    on_attach = function(client, bufnr)
      -- TypeScriptのフォーマットを無効化（Biomeを使うため）
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      -- 共通のon_attachを呼ぶ
      common.on_attach(client, bufnr)

      -- TypeScript固有のキーバインド
      local opts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set('n', '<leader>oi', function()
        vim.lsp.buf.execute_command({
          command = '_typescript.organizeImports',
          arguments = { vim.api.nvim_buf_get_name(0) },
        })
      end, opts)
    end,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      }
    }
  })
end

return M
