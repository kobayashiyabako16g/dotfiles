local common = require('config.lsp.common')

local M = {}

function M.setup()
  vim.lsp.config('ts_ls', {
    capabilities = common.capabilities,
    root_markers = { 'package.json', 'tsconfig.json', '.git' },
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      common.on_attach(client, bufnr)

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
  vim.lsp.enable('ts_ls')
end

return M
