{ pkgs }:

pkgs.buildEnv {
  name = "font";
  paths = [
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
