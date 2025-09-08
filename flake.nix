{
  description = "thymos dev flake";

  # Dependencies
  inputs = {
    flake-utils.url = "github:Numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zig.url = "github:mitchellh/zig-overlay";
  };

  # Things to do after fetching all inputs
  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = with inputs; [zig.overlays.default];
      };
    in {
      devShells.default = pkgs.mkShellNoCC {
        nativeBuildInputs = with pkgs; [
          gcc # Makefile and `cc` for compiling Limine binaries
          zigpkgs.master # Compiler
          xorriso # For creating the ISO
          qemu # For emulating the OS
          wget # For fetching dependencies
        ];
      };
    });
}
