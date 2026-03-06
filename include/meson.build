# Tiny printf
printfLib = static_library(
	'printf',
	sources: 'printf/printf.c',
	include_directories: incDirs,
	c_args: ['-Wno-pedantic'],
	pic: false,
)
printfDep = declare_dependency(
	link_with: printfLib,
	include_directories: incDirs,
)
