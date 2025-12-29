{
  description = "Split flake with dev-tools and language environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "aarch64-darwin";

    pkgs = import nixpkgs {
        system = system;
        overlays = [
          (final: prev: {
            k3d = prev.k3d.override {
              k3sVersion = "1.32.5-k3s1";
            };
          })
        ];
      };

    # 分割した定義を読み込む
    devTools = import ./nix/pkgs/dev-tools.nix { inherit pkgs; };
    languages = import ./nix/pkgs/languages.nix { inherit pkgs; };
    font = import ./nix/pkgs/font.nix { inherit pkgs; };

  in {
    packages.${system} = {
      dev-tools = devTools;
      languages = languages;
      font = font;

      everything = pkgs.buildEnv {
        name = "everything";
        paths = [ devTools languages font ];
      };
    };
  };
}
