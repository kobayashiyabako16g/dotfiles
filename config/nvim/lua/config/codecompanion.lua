require('codecompanion').setup({
  display = {
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ",                   -- Prompt used for interactive LLM calls
      provider = "default",                 -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
      opts = {
        show_default_actions = true,        -- Show the default actions in the action palette?
        show_default_prompt_library = true, -- Show the default prompt library in the action palette?
        title = "CodeCompanion actions",    -- The title of the action palette
      },
    },
  },
  strategies = {
    chat = {
      adapter = "claude_code",
    },
    cli = {
      agent = "claude_code",
      agents = {
        claude_code = {
          cmd = "claude",
          args = {},
          description = "Claude Code CLI",
          provider = "terminal",
        },
      },
    },
  }
})

-- チャット / CLI ウィンドウの幅をキーで動的に変更する
local function resize(delta)
  return function()
    vim.cmd("vertical resize " .. (delta > 0 and "+" or "") .. delta)
  end
end

-- 最大化 ⇔ 元の幅をトグル（元の幅はウィンドウ変数に保存）
local function toggle_max()
  local win = vim.api.nvim_get_current_win()
  if vim.w[win].cc_prev_width then
    vim.api.nvim_win_set_width(win, vim.w[win].cc_prev_width)
    vim.w[win].cc_prev_width = nil
  else
    vim.w[win].cc_prev_width = vim.api.nvim_win_get_width(win)
    vim.api.nvim_win_set_width(win, vim.o.columns - 20)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "codecompanion", "codecompanion_cli" },
  callback = function(ev)
    local o = { buffer = ev.buf, silent = true }
    vim.keymap.set({ "n", "t" }, "<M-l>", resize(5), vim.tbl_extend("force", o, { desc = "CodeCompanion: Widen" }))
    vim.keymap.set({ "n", "t" }, "<M-h>", resize(-5), vim.tbl_extend("force", o, { desc = "CodeCompanion: Narrow" }))
    vim.keymap.set({ "n", "t" }, "<M-=>", toggle_max, vim.tbl_extend("force", o, { desc = "CodeCompanion: Toggle maximize" }))
  end,
})
