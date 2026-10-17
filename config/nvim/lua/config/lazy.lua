-- optional プラグインをコマンド実行時に packadd する (dpp の on_cmd 相当)
local function on_cmd(pack, cmds, setup)
  local loaded = false

  local function load()
    if loaded then
      return
    end
    loaded = true
    for _, cmd in ipairs(cmds) do
      pcall(vim.api.nvim_del_user_command, cmd)
    end
    vim.cmd.packadd(pack)
    setup()
  end

  for _, cmd in ipairs(cmds) do
    vim.api.nvim_create_user_command(cmd, function(args)
      load()
      vim.cmd(string.format("%s%s %s", cmd, args.bang and "!" or "", args.args))
    end, { nargs = "*", bang = true, range = true })
  end
end

on_cmd("neo-tree.nvim", { "Neotree" }, function()
  require("config/neotree")
end)

on_cmd("codecompanion.nvim", { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" }, function()
  require("config/codecompanion")
end)
