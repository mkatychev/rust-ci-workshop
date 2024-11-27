# $ nix run '.#hw-server'
{
  description = "Build a cargo project without extra checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      crane,
      flake-utils,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # libs
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;

        craneLib = crane.mkLib pkgs;
        helloworld = craneLib.buildPackage {
          src = craneLib.cleanCargoSource ./helloworld;

          buildInputs =
            [
              pkgs.protobuf_26
              # Add additional build inputs here
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
              # Additional darwin specific inputs can be set here
              pkgs.libiconv
            ];
        };

      in
      {
        checks = { };

        packages = {
          actionlint = pkgs.actionlint;
          bash = pkgs.bash;
          shfmt = pkgs.shfmt;
          cargo-nextest = pkgs.cargo-nextest;
          fd = pkgs.fd;
          just = pkgs.just;
          protoc = pkgs.protobuf_26;
          zellij = pkgs.zellij;
          shellcheck = pkgs.shellcheck;
          # rustup = pkgs.rustup;
          # NOTE sucks: compiles from source
          # https://github.com/hadolint/hadolint?tab=readme-ov-file#install
          # hadolint = pkgs.hadolint;

        };
        devShells.default = craneLib.devShell {
          # Automatically inherit any build inputs from `my-crate`
          inputsFrom = [ helloworld ];

          # Extra inputs (only used for interactive development)
          # can be added here; cargo and rustc are provided by default.
          packages = [
            pkgs.cargo-nextest
            pkgs.just
          ];
        };

        # TODO
        apps = with flake-utils.lib; {
          default = mkApp {
            drv = server;
            exePath = "/bin/hw-server";
          };
        };

      }
    );
}
