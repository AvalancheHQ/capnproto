{
  description = "Cap'n Proto development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Clang toolchain
            clang_20
            llvmPackages_20.lld
            llvmPackages_20.bintools
            llvmPackages_20.libcxx

            # Build system
            bazelisk
            gcc  # fallback

            # Development tools
            cmake
            ninja
            pkg-config
            git

            # Cap'n Proto specific
            openssl
            zlib
            brotli
          ];

          shellHook = ''
            export CC=clang-20
            export CXX=clang++-20
            export BAZEL_ARGS="--config=profile --@google_benchmark//:codspeed_mode=instrumentation"
          '';
        };

        # Development shell with debugging tools
        devShells.cpp-dev = pkgs.mkShell {
          buildInputs = with pkgs; [
            clang_20
            llvmPackages_20.lld
            llvmPackages_20.bintools
            llvmPackages_20.libcxx
            bazelisk
            gdb
            valgrind
            ccache
            openssl
            zlib
            brotli
          ];

          shellHook = ''
            export CC=clang-20
            export CXX=clang++-20
          '';
        };
      }
    );
}
