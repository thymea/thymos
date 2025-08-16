{
  description = "My x86 64-bit hobby operating system written from scratch in Zig";

  # Dependencies
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:Numtide/flake-utils";
  };

  # Things to do after fetching all inputs
  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShellNoCC {
        nativeBuildInputs = with pkgs; [
          gcc # Makefile and `cc` for compiling Limine binaries
          zig # Compiler
          nasm # Assembler
          xorriso # For creating the ISO
          qemu # For emulating the OS
          wget # For fetching dependencies
        ];
      };
    });
}
