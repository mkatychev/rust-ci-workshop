# $ nix run '.#hw-server'
{
  description = "Build a cargo project without extra checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # libs
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;

        craneLib = crane.lib.${system};

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
          shellcheck = pkgs.shellcheck;
          # rustup = pkgs.rustup;
          # NOTE sucks: compiles from source
          # https://github.com/hadolint/hadolint?tab=readme-ov-file#install
          # hadolint = pkgs.hadolint;

        };

        # TODO
        apps =
          with flake-utils.lib;
          { default = mkApp { drv = server; exePath = "/bin/hw-server"; }; };

      });
}



