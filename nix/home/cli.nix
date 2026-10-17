{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
  };

  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.lazygit.enable = true;
  programs.bottom.enable = true;
  programs.htop.enable = true;
}
