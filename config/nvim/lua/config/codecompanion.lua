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
  adapters = {
    acp = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "cmd:op read op://develop/claude/Agent/api-key --no-newline",
          },
        })
      end,
    }
  },
  strategies = {
    chat = {
      adapter = "anthropic",
      model = "claude-sonnet-4-20250514"
    },
  }
})
