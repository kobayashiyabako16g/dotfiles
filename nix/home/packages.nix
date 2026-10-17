{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # dev tools
    jq
    tree
    gawk
    gnupg
    herdr
    coreutils
    libpq
    netcat
    sqlite
    ripgrep
    kubectl
    k3d
    posting
    devenv
    devbox
    tree-sitter
    typst
    tdf
    git-wt
    terminal-notifier

    # languages
    rustup
    go
    deno

    # font
    nerd-fonts.jetbrains-mono
  ];

  # stable toolchain が未導入なら入れる
  home.activation.rustupDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.rustup}/bin/rustup toolchain list | grep -q '^stable'; then
      run ${pkgs.rustup}/bin/rustup default stable
    fi
  '';
}
