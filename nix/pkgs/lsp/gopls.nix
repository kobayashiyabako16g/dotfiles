{ buildGoModule, fetchFromGitHub }:

buildGoModule (finalAttrs: {
  pname = "gopls";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "tools";
    tag = "gopls/v${finalAttrs.version}";
    hash = "sha256-MX66CdQDrM8wdDmrAHRLvoKH9Y5hJ97A6Z1HrmFuHc0=";
  };

  modRoot = "gopls";
  vendorHash = "sha256-YGB5qzoyU4I1yp9rxaE3KZLphTcn0DJRG/Z1WvP6pVM=";
  subPackages = [ "." ];
  ldflags = [ "-X main.version=v${finalAttrs.version}" ];
  doCheck = false;
})
