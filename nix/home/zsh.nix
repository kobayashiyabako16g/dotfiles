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

        # [ghq + fzf] リポジトリ管理コマンド
        ghr() {
            local action="''${1:-list}"

            case "$action" in
                "list"|"l")
                    # List all repositories with fzf selection
                    local selected_repo
                    selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap)
                    if [[ -n "$selected_repo" ]]; then
                        echo "Selected: $selected_repo"
                        echo "Path: $(ghq root)/$selected_repo"
                    fi
                    ;;
                "cd"|"c")
                    # Change directory to selected repository
                    local selected_repo
                    selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap)
                    if [[ -n "$selected_repo" ]]; then
                        cd "$(ghq root)/$selected_repo" || return 1
                    fi
                    ;;
                "remove"|"rm"|"r")
                    # Remove selected repository
                    local selected_repo
                    selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap --prompt="Select repository to remove: ")
                    if [[ -n "$selected_repo" ]]; then
                        echo "Are you sure you want to remove $selected_repo? [y/N]"
                        read -r confirm
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            rm -rf "$(ghq root)/$selected_repo"
                            echo "Removed: $selected_repo"
                        else
                            echo "Cancelled"
                        fi
                    fi
                    ;;
                "get"|"g")
                    # Clone/get a new repository
                    if [[ -z "$2" ]]; then
                        # Interactive mode: show remote repositories via gh + fzf
                        local selected_repo
                        selected_repo=$(gh repo list --limit 100 --json nameWithOwner --jq '.[].nameWithOwner' | fzf --height=50% --border --preview="gh repo view {} --json description,url,pushedAt --template '{{.description}}\n{{.url}}\nLast updated: {{.pushedAt}}'" --preview-window=down:5:wrap --prompt="Select repository to clone: ")
                        if [[ -n "$selected_repo" ]]; then
                            ghq get "github.com/$selected_repo"
                        fi
                    else
                        ghq get "$2"
                    fi
                    ;;
                "create"|"new"|"n")
                    # Create a new repository directory
                    if [[ -z "$2" ]]; then
                        echo "Usage: ghr create <repository_path>"
                        echo "Example: ghr create github.com/user/new-repo"
                        return 1
                    fi
                    local repo_path="$(ghq root)/$2"
                    mkdir -p "$repo_path"
                    cd "$repo_path" || return 1
                    git init
                    echo "Created and initialized: $2"
                    ;;
                "open"|"o")
                    # Open repository in editor (default: code)
                    local editor="''${2:-code}"
                    local selected_repo
                    selected_repo=$(ghq list | fzf --height=50% --border --preview="echo {}" --preview-window=down:3:wrap)
                    if [[ -n "$selected_repo" ]]; then
                        local repo_path="$(ghq root)/$selected_repo"
                        if command -v "$editor" > /dev/null; then
                            "$editor" "$repo_path"
                        else
                            echo "Editor '$editor' not found. Trying fallback editors..."
                            if command -v code > /dev/null; then
                                code "$repo_path"
                            elif command -v vim > /dev/null; then
                                vim "$repo_path"
                            else
                                echo "No suitable editor found (code, vim)"
                            fi
                        fi
                    fi
                    ;;
                "help"|"h"|*)
                    # Show help
                    cat << 'EOF'
        Repository management with ghq and fzf

        Usage: ghr <command> [args]

        Commands:
          list, l         List repositories with fzf selection
          cd, c           Change directory to selected repository
          remove, rm, r   Remove selected repository (with confirmation)
          get, g [url]    Clone repository (interactive if no url)
          create, new, n  Create and initialize a new repository
          open, o [editor] Open repository in editor (default: code)
          help, h         Show this help message

        Examples:
          ghr                     # List repositories
          ghr cd                  # Change to selected repository
          ghr get                 # Interactive repository selection
          ghr get github.com/user/repo
          ghr create github.com/user/new-repo
          ghr remove              # Remove selected repository
          ghr open                # Open repository in code (default)
          ghr open vim            # Open repository in vim
          ghr open nvim           # Open repository in neovim

        Requirements: ghq, fzf, git, gh (for interactive get)
        EOF
                    ;;
            esac
        }

        # 遅延読み込み
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
