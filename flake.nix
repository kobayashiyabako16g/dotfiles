{
  description = "dotfiles managed by nix-darwin and home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # blink.cmp v2 (main ブランチ, 未リリース)
    blink-cmp = {
      url = "github:saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, blink-cmp }: let
    # 端末ごとにユーザー名が異なるため、sudo 実行元のユーザーを使う (--impure が必要)
    username = let
      sudoUser = builtins.getEnv "SUDO_USER";
      user = if sudoUser != "" then sudoUser else builtins.getEnv "USER";
    in
      if user == "" || user == "root"
      then throw "ユーザー名を取得できません。`sudo darwin-rebuild switch --flake ~/dotfiles --impure` で実行してください"
      else user;
    # 同じネットワーク上の端末と名前が衝突しないよう、端末ごとに Git 管理外のファイルで指定する (--impure が必要)
    hostnameFile = "/etc/nix/darwin-hostname";
    hostname = let
      name = builtins.replaceStrings [ "\n" " " ] [ "" "" ]
        (if builtins.pathExists hostnameFile then builtins.readFile hostnameFile else "");
    in
      if builtins.match "[A-Za-z0-9-]+" name == null
      then throw "ホスト名を取得できません。`echo <hostname> | sudo tee ${hostnameFile}` で英数字とハイフンのみの名前を設定してください"
      else name;
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self username hostname; };
      modules = [
        ./nix/darwin
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bak";
            extraSpecialArgs = { inherit username; };
            users.${username} = import ./nix/home;
          };
        }
      ];
    };
  };
}
