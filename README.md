<div align="center">
	<h1>thymos</h1>

$${\color{red}a \space simple \space x86 \textunderscore 64 \space operating \space system \space in \space c++}$$

![GitHub License](https://img.shields.io/github/license/thymea/thymos?style=for-the-badge&label=License&labelColor=black&color=white)
![GitHub repo size](https://img.shields.io/github/repo-size/thymea/thymos?style=for-the-badge&label=size&labelColor=black&color=white)
![GitHub Repo stars](https://img.shields.io/github/stars/thymea/thymos?style=for-the-badge&labelColor=black&color=white)

</div>

## Build Dependencies
- [Meson](https://mesonbuild.com/) - The build system. You'll also need [Ninja](https://ninja-build.org/) as Meson will use Ninja as it's backend and won't work without it.
- [GCC cross-compiler](https://wiki.osdev.org/GCC_Cross-Compiler) - C/C++ compiler. Should also include the `make` utility which is used to provide a a nice and easy to use interface to build/run thymos by running Meson commands in the background. Also you'll need to run `make fetchDeps` to fetch all dependencies/libraries so uh, yeah.
- [NASM](https://www.nasm.us/) - Assembler.
- [QEMU](https://www.qemu.org/) - Emulator.
- [Xorriso](https://www.gnu.org/software/xorriso/) - For creating the bootable ISO. Found in `libisoburn` package in certain software repos e.g. Nix packages.
- [Git](https://git-scm.com/) and [wget](https://www.gnu.org/software/wget/) - To fetch dependencies.

> [!NOTE]
> For those using Nix, ensure you have flakes enabled and then run `nix develop` to enter the provided development shell with all dependencies already installed. Also update the flake every now and then to have the latest packages installed.

## Building
> [!NOTE]
> Please run `make fetchDeps` before trying to build/run thymos or else you will get a lot of errors for obvious reasons.

- `make fetchDeps` - Fetch all libraries e.g. Limine. `git` and `wget` are used for this.
- `make` or `make kernel` - Build the kernel.
- `make iso` - Build the bootable ISO
- `make run` - Emulate OS using QEMU.
- `make clean` - Clean up all build outputs.

<div align="center">
	<h2>Contributors</h2>
	<a href="https://github.com/thymea/thymos/graphs/contributors">
		<img src="https://contrib.rocks/image?repo=thymea/thymos"/>
	</a>
	<p>Made with <a href="https://contrib.rocks/">contrib.rocks</a></p>
</div>
