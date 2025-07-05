{ pkgs }:

pkgs.buildEnv {
  name = "nvim";
  paths = [
    pkgs.vimPlugins.denops-vim
  ];
}
