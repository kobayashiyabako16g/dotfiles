local M = {}

-- LSPツールのPATH設定
function M.setup_tools_path()
  local config_dir = vim.fn.stdpath('config')
  local node_tools_bin = config_dir .. '/lua/config/lsp/servers/node/node_modules/.bin'

  if vim.fn.isdirectory(node_tools_bin) == 1 then
    vim.env.PATH = node_tools_bin .. ':' .. vim.env.PATH
  end
end

-- プロジェクトのnode_modules/.binにもPATHを通す
function M.setup_project_bin()
  local node_modules_bin = vim.fn.getcwd() .. '/node_modules/.bin'
  if vim.fn.isdirectory(node_modules_bin) == 1 then
    vim.env.PATH = node_modules_bin .. ':' .. vim.env.PATH
  end
end

M.on_attach = function(client, bufnr)
  -- 基本的なキーマッピング
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)

  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function()
    vim.lsp.buf.format { async = true }
  end, bufopts)

  if vim.lsp.inlay_hint then
    vim.keymap.set('n', '<leader>ih', function()
      vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
    end, bufopts)
  end
end

-- 共通のcapabilities
M.capabilities = require('cmp_nvim_lsp').default_capabilities()

-- 診断設定
M.setup_diagnostics = function()
  local signs = {
    Error = "󰅚 ",
    Warn = "󰀪 ",
    Hint = "󰌶 ",
    Info = " ",
  }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.diagnostic.config({
    virtual_text = {
      prefix = '●',
      spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })
end

return M
