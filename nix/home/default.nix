{ username, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./zsh.nix
    ./tmux.nix
    ./ghostty.nix
    ./neovim.nix
    ./cli.nix
    ./links.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "26.11";
  };

  xdg.enable = true;

  programs.home-manager.enable = true;
}
