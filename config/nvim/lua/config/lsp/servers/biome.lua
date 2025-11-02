-- Biome設定

local M = {}

-- Dotfiles内のBiomeコマンドパス
local function get_dotfiles_biome()
  local config_dir = vim.fn.stdpath('config')
  return config_dir .. '/lua/config/lsp/servers/node/node_modules/.bin/biome'
end

-- プロジェクト内のBiomeコマンドパス
local function get_project_biome()
  return vim.fn.getcwd() .. '/node_modules/.bin/biome'
end

-- 使用するBiomeコマンドを決定（プロジェクト優先）
local function find_biome_cmd()
  local project_biome = get_project_biome()
  if vim.fn.executable(project_biome) == 1 then
    return project_biome
  end

  local dotfiles_biome = get_dotfiles_biome()
  if vim.fn.executable(dotfiles_biome) == 1 then
    return dotfiles_biome
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

-- Biomeでフォーマット
function M.format()
  local file = vim.fn.expand('%:p')
  local biome_cmd = find_biome_cmd()
  local config_path = find_biome_config()

  -- プロジェクトにbiome.jsonがない場合は実行しない
  if not config_path then
    return
  end

  local view = vim.fn.winsaveview()
  vim.cmd('write')

  local config_dir = vim.fn.fnamemodify(config_path, ':h')
  local cmd = string.format('cd %s && %s format --write %s',
    vim.fn.shellescape(config_dir),
    biome_cmd,
    vim.fn.shellescape(file))

  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify('Biome format failed: ' .. result, vim.log.levels.ERROR)
  else
    vim.cmd('edit!')
    vim.fn.winrestview(view)
  end
end

-- Biomeでlint
function M.lint()
  local file = vim.fn.expand('%:p')
  local biome_cmd = find_biome_cmd()
  local config_path = find_biome_config()

  if not config_path then
    vim.notify('No biome.json found in project', vim.log.levels.WARN)
    return
  end

  local config_dir = vim.fn.fnamemodify(config_path, ':h')
  local cmd = string.format('cd %s && %s lint %s',
    vim.fn.shellescape(config_dir),
    biome_cmd,
    vim.fn.shellescape(file))

  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify(output, vim.log.levels.WARN)
  else
    vim.notify('No lint errors', vim.log.levels.INFO)
  end
end

-- Biomeでcheck
function M.check()
  local file = vim.fn.expand('%:p')
  local biome_cmd = find_biome_cmd()
  local config_path = find_biome_config()

  if not config_path then
    vim.notify('No biome.json found in project', vim.log.levels.WARN)
    return
  end

  local view = vim.fn.winsaveview()
  vim.cmd('write')

  local config_dir = vim.fn.fnamemodify(config_path, ':h')
  local cmd = string.format('cd %s && %s check --write %s',
    vim.fn.shellescape(config_dir),
    biome_cmd,
    vim.fn.shellescape(file))

  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify('Biome check found issues: ' .. result, vim.log.levels.WARN)
  else
    vim.notify('Biome check passed', vim.log.levels.INFO)
  end

  vim.cmd('edit!')
  vim.fn.winrestview(view)
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
