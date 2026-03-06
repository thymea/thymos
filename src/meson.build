# Assembly
asm = find_program('nasm', required: true)
asmFormat = 'elf64'
asmFiles = meson.project_source_root() / 'src/arch/' + arch + '/asm.s'
asmGen = generator(
	asm,
	output: '@BASENAME@.o',
	arguments : ['-f', asmFormat, '@INPUT@', '-o', '@OUTPUT@'],
)
asmObjs = asmGen.process(asmFiles)

# Kernel binary
linkerScript = meson.project_source_root() / 'src' / 'arch' / arch / 'linker.ld'
# Find source files
cppFiles = run_command(
	'find', './', '-name', '*.cpp', '-type', 'f',
	check: true,
).stdout().strip().split('\n')
kernel = executable(
	osName,
	sources: cppFiles + asmObjs + sfnObjs,
	include_directories: incDirs,
	dependencies: [printfDep],
	link_args: ['-T', linkerScript],
)
