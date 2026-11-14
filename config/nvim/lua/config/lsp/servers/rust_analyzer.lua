local common = require('config.lsp.common')

local M = {}

local function rust_on_attach(client, bufnr)
  -- 共通設定を適用
  common.on_attach(client, bufnr)

  -- 保存時に rustfmt でフォーマット（該当バッファのみ）
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ async = false })
    end
  })

  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', '<leader>rr', ':TermExec cmd="cargo run"<CR>', vim.tbl_extend("force", bufopts, { desc = "Cargo Run" }))
  vim.keymap.set('n', '<leader>rt', ':TermExec cmd="cargo test"<CR>', vim.tbl_extend("force", bufopts, { desc = "Cargo Test" }))
end

M.setup = function()
  vim.lsp.config('rust_analyzer', {
    on_attach = rust_on_attach,
    capabilities = common.capabilities,
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    settings = {
      ["rust-analyzer"] = {
        -- 保存時のチェックに clippy を使う
        check = { command = "clippy" },

        cargo = {
          allFeatures = true,
          buildScripts = { enable = true },
        },
        procMacro = { enable = true },

        -- インレイヒント
        inlayHints = {
          bindingModeHints = { enable = true },
          closureReturnTypeHints = { enable = "with_block" },
          lifetimeElisionHints = { enable = "skip_trivial" },
          parameterHints = { enable = true },
          typeHints = { enable = true },
        },

        -- 補完設定
        completion = {
          postfix = { enable = true },
        },
      },
    },
  })
  vim.lsp.enable('rust_analyzer')
end

return M
