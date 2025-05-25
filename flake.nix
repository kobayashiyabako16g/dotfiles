{
  description = "Split flake with dev-tools and language environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};

    # 分割した定義を読み込む
    devTools = import ./nix/pkgs/dev-tools.nix { inherit pkgs; };
    languages = import ./nix/pkgs/languages.nix { inherit pkgs; };
  in {
    packages.${system} = {
      dev-tools = devTools;
      languages = languages;

      everything = pkgs.buildEnv {
        name = "everything";
        paths = [ devTools languages ];
      };
    };
  };
}
