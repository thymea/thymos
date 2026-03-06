# Find files
linkerScript = meson.project_source_root() / 'src' / 'arch' / arch / 'linker.ld'
asmFile = meson.project_source_root() / 'src/arch/' + arch + '/asm.s'
cppFiles = run_command(
	'find', './', '-name', '*.cpp', '-type', 'f',
	check: true,
).stdout().strip().split('\n')

# Assemble assembly files
asm = find_program('nasm', required: true)
asmFormat = 'elf64'
asmGen = generator(
	asm,
	output: '@BASENAME@.o',
	arguments : ['-f', asmFormat, '@INPUT@', '-o', '@OUTPUT@'],
)
asmObj = asmGen.process(asmFile)

# Kernel binary
kernel = executable(
	osName,
	sources: cppFiles + asmObj + sfnObjs,
	include_directories: incDirs,
	dependencies: [printfDep],
	link_args: ['-T', linkerScript],
)
