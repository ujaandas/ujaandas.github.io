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
        pkgs = nixpkgs.legacyPackages.${system};
        site = oojsite.defaultPackage.${system};
      in
      {
        packages.site = site;
        defaultPackage = site;

        devShell = pkgs.mkShell {
          buildInputs = [
            site
            pkgs.watchexec
          ];
        };

        packages.website = pkgs.stdenv.mkDerivation {
          name = "my-website";
          src = ./.;

          buildInputs = [ site ];

          buildPhase = ''
            ${site}/bin/oojsite build --output $out
          '';
        };
      }
    );
}
