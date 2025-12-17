{
  description = "Personal website flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    oojsite.url = "github:ujaandas/oojsite";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      oojsite,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # pkgs = nixpkgs.legacyPackages.${system};
        site = oojsite.defaultPackage.${system};
      in
      {
        packages.site = site;
        defaultPackage = site;
      }
    );
}
