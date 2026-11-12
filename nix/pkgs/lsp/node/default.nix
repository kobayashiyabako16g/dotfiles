{ lib, buildNpmPackage, importNpmLock, jq }:

# package-lock.json の resolved/integrity から依存を取得するため npmDepsHash は不要
buildNpmPackage {
  pname = "nvim-lsp-node";
  version = "0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [ ./package.json ./package-lock.json ];
  };

  npmDeps = importNpmLock { npmRoot = ./.; };
  npmConfigHook = importNpmLock.npmConfigHook;
  dontNpmBuild = true;

  nativeBuildInputs = [ jq ];

  # package.json の dependencies に書いたパッケージの bin だけを $out/bin に出す
  # (ツールの追加・入れ替えは package.json の編集だけで済む)
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r node_modules $out/lib/
    for pkg in $(jq -r '.dependencies | keys[]' package.json); do
      for bin in $(jq -r --arg name "''${pkg##*/}" \
        'if (.bin | type) == "string" then $name else (.bin // {} | keys[]) end' \
        node_modules/$pkg/package.json); do
        ln -s $out/lib/node_modules/.bin/$bin $out/bin/$bin
      done
    done
    runHook postInstall
  '';
}
