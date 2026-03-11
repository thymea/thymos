{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
		systems.url = "github:nix-systems/default";
		zig.url = "github:mitchellh/zig-overlay";
	};
	outputs = inputs: let
		forEachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
		pkgs = forEachSystem(system: import inputs.nixpkgs {
			inherit system;
			overlays = [inputs.zig.overlays.default];
		});
	in {
		devShells = forEachSystem(system: {
			default = pkgs.${system}.mkShellNoCC {
				nativeBuildInputs = with pkgs.${system}; [
					# Toolchain
					zigpkgs.master
					zls
					gcc

					# Emulator
					qemu

					# For creating bootable ISOs using `xorriso`
					libisoburn

					# For fetching dependencies/libraries
					git
					curl
				];
			};
		});
	};
}
