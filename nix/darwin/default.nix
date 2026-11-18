{ self, username, hostname, ... }:

{
  imports = [ ./homebrew.nix ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    # claude-agent-acp (codecompanion の ACP アダプタ) が依存する claude-code のみ unfree を許可する
    config.allowUnfreePredicate = pkg: builtins.elem (pkg.pname or (builtins.parseDrvName pkg.name).name) [ "claude-code" ];
    overlays = [
      (import ../overlays.nix)
      # vimPlugins.blink-lib / vimPlugins.blink-cmp (v2) を差し替える
      self.inputs.blink-cmp.inputs.blink-lib.overlays.default
      self.inputs.blink-cmp.overlays.default
    ];
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@admin" ];
    };
    # GitHub の access-tokens は Git 管理外のこのファイルに置く (存在しなければ無視される)
    extraOptions = ''
      !include /etc/nix/access-tokens.conf
    '';
  };

  networking = {
    hostName = hostname;
    localHostName = hostname;
    computerName = hostname;
  };

  # /etc/zshenv で nix-daemon の環境を読み込む
  programs.zsh.enable = true;

  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
}
