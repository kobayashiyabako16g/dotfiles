{ pkgs }:

pkgs.buildEnv {
  name = "dev-tools";
  paths = [
    pkgs.git
    pkgs.jq
    pkgs.tree
    pkgs.gawk
    pkgs.gnupg
    pkgs.tmux
    pkgs.coreutils
    pkgs.libpq
    pkgs.netcat
    pkgs.sheldon
    pkgs.direnv
    pkgs.sqlite
    pkgs.fzf
    pkgs.ripgrep
    pkgs.bat
    pkgs.lazygit
    pkgs.kubectl
    pkgs.k3d
    pkgs.neovim
    pkgs.posting
    pkgs.bottom
    pkgs.htop
    pkgs.devenv
    pkgs.tree-sitter
    pkgs.zoxide
  ];
}
