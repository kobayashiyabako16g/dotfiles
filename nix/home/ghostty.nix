{ ... }:

{
  programs.ghostty = {
    enable = true;
    # 本体は Homebrew cask で管理
    package = null;
    settings = {
      theme = "Catppuccin Mocha";

      # Window
      window-padding-x = 20;
      window-padding-y = 5;
      window-padding-balance = true;
      window-theme = "ghostty";
      background-opacity = 0.90;
      background-blur-radius = 20;
      macos-titlebar-style = "transparent";
      confirm-close-surface = false;
      resize-overlay = "never";
      gtk-toolbar-style = "flat";

      # Font
      font-family = "Hack Nerd Font Mono";
      font-style = "Regular";
    };
  };
}
