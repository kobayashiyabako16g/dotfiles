final: prev: {
  # nixpkgs の更新と切り離してバージョン固定した LSP (nix/pkgs/lsp)
  lsp = final.callPackage ./pkgs/lsp { };

  ghq = prev.ghq.overrideAttrs (finalAttrs: _: {
    version = "1.11.2";
    src = prev.fetchFromGitHub {
      owner = "x-motemen";
      repo = "ghq";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Ro/PbI9UZ0l0OsfIQOlmX8GZBWBvAeKDgHpz8DrsQPM=";
    };
    vendorHash = "sha256-YToIkJozCyI1k5xqs4w6brVERJ2edR2PRob2tXWb9Ms=";
  });
}
