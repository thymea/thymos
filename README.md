<div align="center">
	<h1>thymos</h1>

$${\color{red}x86 \textunderscore 64 \space bit \space operating \space system \space in \space zig}$$

![GitHub License](https://img.shields.io/github/license/Voxi0/thymos1?style=for-the-badge&label=License&labelColor=black&color=white)
![GitHub repo size](https://img.shields.io/github/repo-size/Voxi0/thymos1?style=for-the-badge&label=size&labelColor=black&color=white)
![GitHub Repo stars](https://img.shields.io/github/stars/Voxi0/thymos?style=for-the-badge&labelColor=black&color=white)

</div>

## Build Dependencies
> [!NOTE]
> Nix users are able to enable flakes and run `nix develop` in the same directory as the `flake.nix` in thymos to enter the provided development shell with all of these dependencies already installed.

- [Zig](https://ziglang.org/) - Obviously you need Zig to build thymos since it's written in Zig believe it or not.
- [GNU Make](https://www.gnu.org/software/make/manual/make.html) - I mainly rely on the Zig build system but honestly Makefiles are super convenient and I use one to just wrap around Zig's build system and also some extra things like fetching dependencies/libraries. I could probably put everything here into `build.zig` but it'd be way more convoluted and painful in my honest opinion.
- [QEMU](https://www.qemu.org/) - Neat emulator for trying out thymos unless you want to boot thymos on real hardware for whatever reason. This is just more convenient than booting thymos on baremetal hardware but you do you.
- [Xorriso](https://www.gnu.org/software/xorriso/) - Creates a bootable ISO.
- [Git](https://git-scm.com/) and [curl](https://curl.se/) - To fetch dependencies/libraries like Limine.

## Building
- `make fetchDeps` - Fetches all required dependencies/libraries. This **MUST** be run first
- `make kernel` - Just builds the kernel
- `make iso` - Creates a bootable ISO
- `make run` - Generates a bootable ISO and runs it using QEMU
- `make cleanDeps` - Deletes all dependencies/libraries
- `make cleanCache` - Deletes `.zig-cache`
- `make clean` - Deletes all build output

<div align="center">
	<h2>Contributors</h2>
	<a href="https://github.com/Voxi0/thymos/graphs/contributors">
		<img src="https://contrib.rocks/image?repo=Voxi0/thymos"/>
	</a>
</div>
