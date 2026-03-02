<div align="center">
	<h1>thymos</h1>

$${\color{red}a \space simple \space x86 \textunderscore 64 \space operating \space system \space in \space c++}$$

![GitHub License](https://img.shields.io/github/license/thymea/thymos?style=for-the-badge&label=License&labelColor=black&color=white)
![GitHub repo size](https://img.shields.io/github/repo-size/thymea/thymos?style=for-the-badge&label=size&labelColor=black&color=white)
![GitHub Repo stars](https://img.shields.io/github/stars/thymea/thymos?style=for-the-badge&labelColor=black&color=white)

</div>

## Build Dependencies
- [Clang](https://clang.llvm.org/) - To compile C++. It's natively a cross compiler and so it's easy to make it cross compile just by adding a target flag so you can just install it and build thymos just fine.
- [NASM](https://www.nasm.us/) - Assembler.
- [QEMU](https://www.qemu.org/) - Emulator.
- [Xorriso](https://www.gnu.org/software/xorriso/) - For creating the ISO. Might be available in `libisoburn` package in certain software repos e.g. Nix packages.
- [Git](https://git-scm.com/) and [wget](https://www.gnu.org/software/wget/) - To fetch dependencies.

> [!NOTE]
> For those using Nix, ensure you have flakes enabled and then run `nix develop` to enter the provided development shell with all dependencies already installed. Also update the flake every now and then to have the latest packages installed.

## Building
- `make fetchDeps` - Fetch all libraries e.g. Limine. `git` and `wget` are used for this. Please run this before trying to build thymos.
- `make` - Build the kernel and output a bootable ISO.
- `make kernel` - Just build the kernel.
- `make run` - Emulate emexOS using QEMU.
- `make clean` - Clean up all build outputs.

<div align="center">
	<h2>Contributors</h2>
	<a href="https://github.com/thymea/thymos/graphs/contributors">
		<img src="https://contrib.rocks/image?repo=thymea/thymos" />
	</a>
	<p>Made with [contrib.rocks](https://contrib.rocks).</p>
</div>
