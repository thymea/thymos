ld = find_program(arch + '-elf-ld', required: true)

sfnFiles = run_command(
	'find', './', '-name', '*.sfn', '-type', 'f',
	check: true
).stdout().strip().split('\n')

sfnObjs = []
foreach file : sfnFiles
	targetName = file.underscorify()
	sfnObjs += custom_target(
		targetName,
		input: file,
		output: '@PLAINNAME@.o',
		command: [ld, '-r', '-b', 'binary', '@INPUT@', '-o', '@OUTPUT@'],
	)
endforeach
