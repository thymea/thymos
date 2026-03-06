project(
	'thymos',
	['c', 'cpp'],
	version: '0.0.1',
	default_options: [
		'cpp_std=c++26',
		'cpp_rtti=false',

		'c_std=c23',

		'warning_level=3',
		'werror=true',

		'buildtype=debugoptimized',
	],
)

# Options
arch = get_option('arch')
osName = get_option('os_name')

# Toolchain
cc = meson.get_compiler('c')
cxx = meson.get_compiler('cpp')

# Directories
incDirs = include_directories('include', 'src')

# Common flags applied to both C/C++ files
commonFlags = [
	'-pedantic-errors',

	'-ffreestanding',
	'-ffunction-sections',
	'-fdata-sections',

	'-m64',
	'-mabi=sysv',
	'-mcmodel=kernel',

	'-mno-80387',
	'-mno-sse2',
	'-mno-red-zone',

	'-fno-builtin',
	'-fno-stack-protector',
	'-fno-lto',
	'-fno-PIE',
	'-fno-PIC',
	'-fno-exceptions',

	'-DPRINTF_INCLUDE_CONFIG_H=1',
]
cxxFlags = commonFlags + [
	'-fno-exceptions',

	'-Wno-c++20-extensions',
	'-Wno-register',

	'-DARCH_' + arch,
]

# Architecture specific flags
if arch == 'x86_64'
	commonFlags += '-march=x86-64'
	cxxFlags += '-march=x86-64'
endif

# Apply flags and stuff
add_project_arguments(commonFlags, language: ['c'])
add_project_arguments(cxxFlags, language: ['cpp'])

# Link options
add_project_link_arguments(
	'-nostdlib',
	'-static',
	'-z',
	'max-page-size=0x1000',
	language: ['c', 'cpp'],
)

# Import `meson.build` from other directories
subdir('include')
subdir('fonts')
subdir('src')

# Create bootable ISO
iso = custom_target(
	'iso',
	input: [kernel],
	output: osName + '.iso',
	build_by_default : true,
	command: [
		'bash', files('scripts/mkISO.sh'),

		# Arguments for the script has to be in this exact order
		# Project root directory, target architecture, kernel binary file and output ISO filename
		meson.project_source_root(),
        arch,
        '@INPUT@',
        '@OUTPUT@',
	],
)

# Emulate OS in QEMU
qemu = find_program('qemu-system-' + arch, required: false)
qemuFlags = ['-m', '512', '-cdrom', 'isodir/' + arch + '/' + osName + '.iso']
if qemu.found()
    run_target(
		'run',
		command: [qemu, qemuFlags],
		depends: [iso],
	)
endif
