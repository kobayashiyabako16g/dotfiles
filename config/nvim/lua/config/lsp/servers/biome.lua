-- Biome設定

local M = {}

-- プロジェクト内のBiomeコマンドパス
local function get_project_biome()
  return vim.fn.getcwd() .. '/node_modules/.bin/biome'
end

-- 使用するBiomeコマンドを決定（プロジェクト優先、なければ Nix で入れた biome）
local function find_biome_cmd()
  local project_biome = get_project_biome()
  if vim.fn.executable(project_biome) == 1 then
    return project_biome
  end

  return 'biome'
end

-- プロジェクトルートを探してbiome.jsonがあるか確認
local function find_biome_config()
  local config_files = { 'biome.json', 'biome.jsonc' }

  local current_dir = vim.fn.getcwd()
  local path = current_dir

  while path ~= '/' do
    for _, config in ipairs(config_files) do
      local config_path = path .. '/' .. config
      if vim.fn.filereadable(config_path) == 1 then
        return config_path
      end
    end
    path = vim.fn.fnamemodify(path, ':h')
  end

  return nil
end

-- Biomeサブコマンドを共通の手順で実行する
-- opts.write: 実行前にバッファを保存し、実行後にリロードするか
-- opts.on_success / opts.on_failure: 結果を受け取る通知処理
local function run_biome(subcommand, opts)
  opts = opts or {}

  local file = vim.fn.expand('%:p')
  local biome_cmd = find_biome_cmd()
  local config_path = find_biome_config()

  if not config_path then
    if opts.warn_if_missing then
      vim.notify('No biome.json found in project', vim.log.levels.WARN)
    end
    return
  end

  local view
  if opts.write then
    view = vim.fn.winsaveview()
    vim.cmd('write')
  end

  local config_dir = vim.fn.fnamemodify(config_path, ':h')
  local cmd = string.format('cd %s && %s %s %s',
    vim.fn.shellescape(config_dir),
    biome_cmd,
    subcommand,
    vim.fn.shellescape(file))

  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    opts.on_failure(result)
  else
    opts.on_success(result)
    if opts.write then
      vim.cmd('edit!')
      vim.fn.winrestview(view)
    end
  end
end

-- Biomeでフォーマット
function M.format()
  run_biome('format --write', {
    write = true,
    on_failure = function(result)
      vim.notify('Biome format failed: ' .. result, vim.log.levels.ERROR)
    end,
    on_success = function() end,
  })
end

-- Biomeでlint
function M.lint()
  run_biome('lint', {
    warn_if_missing = true,
    on_failure = function(output)
      vim.notify(output, vim.log.levels.WARN)
    end,
    on_success = function()
      vim.notify('No lint errors', vim.log.levels.INFO)
    end,
  })
end

-- Biomeでcheck
function M.check()
  run_biome('check --write', {
    write = true,
    warn_if_missing = true,
    on_failure = function(result)
      vim.notify('Biome check found issues: ' .. result, vim.log.levels.WARN)
    end,
    on_success = function()
      vim.notify('Biome check passed', vim.log.levels.INFO)
    end,
  })
end

-- セットアップ（lspconfigは不要）
function M.setup()
  local config_path = find_biome_config()

  -- コマンド登録
  vim.api.nvim_create_user_command('BiomeFormat', M.format, {})
  vim.api.nvim_create_user_command('BiomeLint', M.lint, {})
  vim.api.nvim_create_user_command('BiomeCheck', M.check, {})

  -- キーマップ設定
  vim.keymap.set('n', '<leader>bf', M.format, { desc = 'Biome format' })
  vim.keymap.set('n', '<leader>bl', M.lint, { desc = 'Biome lint' })
  vim.keymap.set('n', '<leader>bc', M.check, { desc = 'Biome check' })

  -- プロジェクトにbiome.jsonがある場合のみ自動フォーマット有効化
  if config_path then
    local biome_group = vim.api.nvim_create_augroup('BiomeFormat', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = biome_group,
      pattern = { '*.ts', '*.tsx', '*.js', '*.jsx', '*.json', '*.jsonc' },
      callback = function()
        M.format()
      end,
    })

    vim.notify('Biome enabled (config: ' .. config_path .. ')', vim.log.levels.INFO)
  end
end

return M
