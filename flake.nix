{
  description = "Personal website flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    oojsite.url = "github:ujaandas/oojsite";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      oojsite,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        baseOojsite = oojsite.defaultPackage.${system};
        commitHash = self.shortRev or self.dirtyShortRev or "unknown";

        mysite = pkgs.writeShellApplication {
          name = "build-site";
          runtimeInputs = [ pkgs.gnused baseOojsite ];
          text = ''
            FOOTER_FILE="components/footer.html"

            if [ -f "$FOOTER_FILE" ]; then
              # Update the URL hash
              sed -i -E "s|/commit/[0-9a-f]+|/commit/${commitHash}|" "$FOOTER_FILE"

              # Update the visible text hash
              sed -i -E "s|@[0-9a-f]+|@${commitHash}|" "$FOOTER_FILE"
              echo "${commitHash} in $FOOTER_FILE"
            else
              echo "Something has gone terribly wrong"
            fi

            ${pkgs.lib.getExe baseOojsite } "$@"
          '';
        };
      in
      {
        packages.site = mysite;
        defaultPackage = mysite;
      }
      );
    }
