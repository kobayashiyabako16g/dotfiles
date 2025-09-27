local common = require('config.lsp.common')

local M = {}

local function go_on_attach(client, bufnr)
  -- 共通設定を適用
  common.on_attach(client, bufnr)

  if client.name == "gopls" then
    -- 保存時にimportを整理とフォーマット
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      buffer = bufnr,
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
        experimentalPostfixCompletions = true,
        analyses = {
          unusedparams = true,
          shadow = true,
          fieldalignment = true,
          nilness = true,
          unusedwrite = true,
          useany = true,
        },
        staticcheck = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        completeUnimported = true,
        usePlaceholders = true,
        matcher = "Fuzzy",
        diagnosticsDelay = "500ms",
        symbolMatcher = "fuzzy",
        symbolStyle = "dynamic",
        vulncheck = "Imports",
        semanticTokens = true,
      },
    },
  }
end

return M
