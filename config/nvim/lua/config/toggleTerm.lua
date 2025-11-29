-- setup
require("toggleterm").setup {
  size = 20,
  open_mapping = [[<C-\>]],
  shade_terminals = true,
  start_in_insert = true,
  persist_size = true,
  persist_mode = true,
  direction = "float",
  float_opts = {
    border = "curved",
  },
}
