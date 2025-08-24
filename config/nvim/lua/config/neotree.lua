local git_available = vim.fn.executable "git" == 1

local sources = {
  { source = "filesystem", display_name = "󰉋 File" },
  { source = "buffers", display_name = " Bufs" },
  { source = "diagnostics", display_name = " Diagnostic" },
}
if git_available then
  table.insert(sources, 3, { source = "git_status", display_name = "󰊢 Git" })
end

require("neo-tree").setup(vim.tbl_deep_extend("force", {
  enable_git_status = git_available,
  auto_clean_after_session_restore = true,
  close_if_last_window = true,
  sources = { "filesystem", "buffers", git_available and "git_status" or nil },
  source_selector = {
    winbar = true,
    content_layout = "center",
    sources = sources,
  },
  default_component_configs = {
    indent = {
      padding = 0,
    },
  },
  commands = {
    system_open = function(state)
      vim.ui.open(state.tree:get_node():get_id())
    end,
    parent_or_close = function(state)
      local node = state.tree:get_node()
      if node:has_children() and node:is_expanded() then
        state.commands.toggle_node(state)
      else
        require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
      end
    end,
    child_or_open = function(state)
      local node = state.tree:get_node()
      if node:has_children() then
        if not node:is_expanded() then
          state.commands.toggle_node(state)
        else
          if node.type == "file" then
            state.commands.open(state)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
          end
        end
      else
        state.commands.open(state)
      end
    end,
    copy_selector = function(state)
      local node = state.tree:get_node()
      local filepath = node:get_id()
      local filename = node.name
      local modify = vim.fn.fnamemodify

      local vals = {
        ["BASENAME"] = modify(filename, ":r"),
        ["EXTENSION"] = modify(filename, ":e"),
        ["FILENAME"] = filename,
        ["PATH (CWD)"] = modify(filepath, ":."),
        ["PATH (HOME)"] = modify(filepath, ":~"),
        ["PATH"] = filepath,
        ["URI"] = vim.uri_from_fname(filepath),
      }

      local options = vim.tbl_filter(function(val)
        return vals[val] ~= ""
      end, vim.tbl_keys(vals))

      if vim.tbl_isempty(options) then
        vim.notify("No values to copy", vim.log.levels.WARN)
        return
      end

      table.sort(options)
      vim.ui.select(options, {
        prompt = "Choose to copy to clipboard:",
        format_item = function(item)
          return ("%s: %s"):format(item, vals[item])
        end,
      }, function(choice)
        local result = vals[choice]
        if result then
          vim.fn.setreg("+", result)
        end
      end)
    end,
  },
  window = {
    width = 30,
    mappings = {
      ["<S-CR>"] = "system_open",
      ["<Space>"] = false,
      ["[b"] = "prev_source",
      ["]b"] = "next_source",
      O = "system_open",
      Y = "copy_selector",
      h = "parent_or_close",
      l = "child_or_open",
    },
    fuzzy_finder_mappings = {
      ["<C-J>"] = "move_cursor_down",
      ["<C-K>"] = "move_cursor_up",
    },
  },
  filesystem = {
    follow_current_file = { enabled = true },
    filtered_items = { hide_gitignored = git_available },
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = vim.fn.has("win32") ~= 1,
  },
}, {}))
