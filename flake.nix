{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
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
          # Build system
          meson
          ninja

          # Compiler and assembler
          pkgsCross.x86_64-embedded.stdenv.cc
          gcc # Only to build Limine
          nasm

          # Emulator
          qemu

          # To create bootable ISOs
          xorriso

          # For fetching dependencies
          git
          wget

          # Extra dev tools
          compiledb
        ];
      };
    });
  };
}
