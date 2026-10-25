final: prev: {
  k3d = prev.k3d.override {
    k3sVersion = "1.32.5-k3s1";
  };

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
