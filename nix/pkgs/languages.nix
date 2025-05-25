{ pkgs }:

pkgs.buildEnv {
  name = "languages";
  paths = [
    pkgs.rustup
    pkgs.go
  ];
}
