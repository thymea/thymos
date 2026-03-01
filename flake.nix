{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };
  outputs = inputs: let
    forEachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
    pkgs = forEachSystem (system:
      import inputs.nixpkgs {
        inherit system;
      });
  in {
    formatter = forEachSystem (system: pkgs.${system}.alejandra);
    devShells = forEachSystem (system: {
      default = pkgs.${system}.mkShellNoCC {
        nativeBuildInputs = with pkgs.${system}; [
					pkgsCross.x86_64-embedded.stdenv.cc
					gcc
					nasm
					qemu
					clang-tools
					compiledb
					xorriso
					git wget
				];
      };
    });
  };
}
