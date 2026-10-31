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
    username = "kobayashishouta";
    hostname = "macbook";
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
