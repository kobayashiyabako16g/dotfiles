{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      size = 1000;
      save = 1000;
      ignoreDups = true;
      ignoreAllDups = true;
    };

    setOptions = [
      # cd -<tab> で以前移動したディレクトリを表示
      "AUTO_PUSHD"
      # history に保存するときに余分なスペースを削除する
      "HIST_REDUCE_BLANKS"
    ];

    autosuggestion.enable = true;

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-defer";
        src = pkgs.zsh-defer;
        file = "share/zsh-defer/zsh-defer.plugin.zsh";
      }
    ];

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
      la = "ls -la";
    };

    sessionVariables = {
      # [pure] https://github.com/sindresorhus/pure
      PURE_PROMPT_SYMBOL = "$";
    };

    profileExtra = ''
      # [homebrew]
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Added by OrbStack: command-line tools and integration
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)
      '')
      ''
        # [pure]
        autoload -U promptinit; promptinit
        prompt pure

        # [devenv]
        eval "$(devenv hook zsh)"

        # [git-wt]
        eval "$(git wt --init zsh)"

        # 遅延読み込み
        # [mise]
        zsh-defer eval "$(/opt/homebrew/bin/mise activate zsh)"
        # [Google Cloud]
        zsh-defer source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
        zsh-defer source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
      ''
    ];
  };

  home.sessionPath = [
    "$HOME/go/bin"
    # [flutter] https://docs.flutter.dev/get-started/install/macos
    "$HOME/workspace/lib/flutter/bin"
  ];
}
