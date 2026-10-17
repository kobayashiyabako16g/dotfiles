{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # Nix 化していない設定は dotfiles を直接参照し、rebuild なしで編集を反映する
  xdg.configFile = {
    "zed".source = link "config/zed";
    "aerospace".source = link "config/aerospace";
    "omniwm".source = link "config/omniwm";
    "herdr".source = link "config/herdr";
  };

  home.file = {
    ".claude/scripts".source = link "claude/scripts";
    ".claude/skills".source = link "claude/skills";
  };
}
