{
  description = "Example development environment flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ruby = pkgs.ruby_3_4;
        packages = with pkgs; [
          # bundix
          bundler
          jekyll
        ];
      in
      # gems = bundlerEnv {
      #   name = "ujaandas.github.io";
      #   inherit ruby;
      #   gemfile = ./Gemfile;
      #   lockfile = ./Gemfile.lock;
      #   gemdir = ./.;
      # };
      {
        devShell = pkgs.mkShell {
          # buildInputs = packages ++ [ gems ];
          buildInputs = packages;
          shellHook = ''
            echo "Welcome to the development shell!"
          '';
        };
      }
    );
}
