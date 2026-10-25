{ ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 動作確認後に "zap" にすると宣言外のパッケージを削除する
      cleanup = "none";
    };
    caskArgs.appdir = "/Applications";

    taps = [
      "fluttergen/tap"
      "supabase/tap"
      "hashicorp/tap"
      "nikitabobko/tap"
      "BarutSRB/tap"
    ];

    brews = [
      "openssl"
      "readline"
      "awscli"
      "fluttergen/tap/fluttergen"
      "supabase/tap/supabase"
      "hashicorp/tap/terraform"
      "gh"
      "arp-scan"
      "kompose"
      "pkg-config"
      "sqlfluff"
      "aws-sam-cli"
    ];

    casks = [
      "nikitabobko/tap/aerospace"
      "omniwm"
      "font-hack-nerd-font"
      "discord"
      "clipy"
      "google-cloud-sdk"
      "dbeaver-community"
      "obsidian"
      "coteditor"
      "the-unarchiver"
      "keyboardcleantool"
      "zed"
      "ghostty"
      "aws-vault"
      "mockoon"
      "karabiner-elements"
      "raycast"
      "slack"
      "visual-studio-code"
      "orbstack"
      "claude-code"
      "1password"
      "1password-cli"
      "zen"
    ];
  };
}
