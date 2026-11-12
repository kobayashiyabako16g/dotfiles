{ callPackage }:

{
  gopls = callPackage ./gopls.nix { };
  node = callPackage ./node { };
}
