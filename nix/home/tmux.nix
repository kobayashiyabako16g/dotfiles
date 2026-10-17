{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-s";
    baseIndex = 1;
    historyLimit = 5000;
    keyMode = "vi";
    mouse = true;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      {
        # https://github.com/catppuccin/tmux
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
        '';
      }
      resurrect
    ];

    extraConfig = ''
      # 設定ファイルをリロードする
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Reloaded!"

      #
      # vim キーバインド
      #

      # コピーモードのキーバインドをvi風にする
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi C-v send -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"

      # ペインの移動をvi風にする
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ペインのリサイズをvi風にする
      bind -r C-h resize-pane -L 10
      bind -r C-l resize-pane -R 10
      bind -r C-j resize-pane -D 10
      bind -r C-k resize-pane -U 10

      #
      #  resize
      #

      # prefix + m でペインのzoom in/zoom out
      bind -T prefix m resize-pane -Z

      # \ でペインを縦分割する
      bind \\ split-window -h -c '#{pane_current_path}'
      bind ^ new-window -c '#{pane_current_path}'

      # - でペインを横分割する
      bind - split-window -v -c '#{pane_current_path}'

      #
      # 外観
      #

      # Make the status line pretty and add some modules
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"

      #
      # その他
      #

      set-option -g default-shell "''${SHELL}"
      bind-key N command-prompt -p "New Session Name:" "new-session -s '%%'"
    '';
  };
}
