require('nvim-treesitter.configs').setup {
  -- インストールする言語パーサー
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "javascript",
    "typescript",
    "python",
    "rust",
    "go",
    "gomod",
    "gowork",
    "gotmpl",
    "html",
    "css",
    "json",
    "yaml",
    "markdown",
    "bash",
    "markdown_inline",
  },

  -- パーサーを同期的にインストール（起動時のみ）
  sync_install = false,

  -- 不足しているパーサーを自動インストール
  auto_install = true,

  -- 無視する言語（パーサーがない場合など）
  ignore_install = {},

  -- 構文ハイライト設定
  highlight = {
    enable = true,
    -- 特定のファイルタイプで無効化する場合
    -- disable = { "c", "rust" },
    -- vim正規表現も併用する場合（重い処理の場合に有効）
    additional_vim_regex_highlighting = false,
  },

  -- インデント設定
  indent = {
    enable = true,
    -- 特定の言語で無効化する場合
    -- disable = { "python" },
  },

  -- インクリメンタル選択
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },

  -- テキストオブジェクト設定
  textobjects = {
    select = {
      enable = true,

      -- 自動的に次のテキストオブジェクトにジャンプ
      lookahead = true,

      keymaps = {
        -- 関数
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        -- クラス
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        -- 条件文
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        -- ループ
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        -- パラメータ/引数
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        -- コメント
        ["a/"] = "@comment.outer",
        ["i/"] = "@comment.inner",
      },
    },

    -- テキストオブジェクト間の移動
    move = {
      enable = true,
      set_jumps = true, -- ジャンプリストに追加
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },

    -- スワップ（入れ替え）
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },

    -- LSPインターフェース（gd、grなどで使用）
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
  },
}

-- treesitter-context設定（現在のコンテキストを上部に表示）
require('treesitter-context').setup {
  enable = true,
  max_lines = 0, -- 0 = 無制限
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = nil,
}
