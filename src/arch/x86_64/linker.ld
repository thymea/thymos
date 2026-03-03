/* Output format */
OUTPUT_FORMAT(elf64-x86-64)

/* Ensure all files being linked together are actually 64-bits */
OUTPUT_ARCH(i386:x86-64)

/* OS Entry point */
ENTRY(kmain)

/* Program headers so the bootloader gives us the right MMU permissions */
/* Also allows us to have more control over the linking process */
PHDRS
{
    limine_requests PT_LOAD;
    text PT_LOAD;
    rodata PT_LOAD;
    data PT_LOAD;
}

SECTIONS
{
	/* Ensure the kernel is placed in the topmost 2GB of the address space for optimizations */
	/* And also because the Limine specifications mandates this */
	/* Any address in this region works but often `0xffffffff80000000` is chosen since it's the beginning of the region */
    . = 0xffffffff80000000;

	/* Limine requests section with it's own PHDR */
    .limine_requests : {
        KEEP(*(.limine_requests_start))
        KEEP(*(.limine_requests))
        KEEP(*(.limine_requests_end))
    } :limine_requests

    /* Move to the next memory page for `.text` */
    . = ALIGN(CONSTANT(MAXPAGESIZE));

	/* Text/Code section */
    .text : {
        *(.text .text.*)
    } :text

    /* Move to the next memory page for `.rodata` */
    . = ALIGN(CONSTANT(MAXPAGESIZE));

	/* Rodata section */
    .rodata : {
        *(.rodata .rodata.*)
    } :rodata

	/* Add a `.note.gnu.build-id` output section in case a build ID flag is added to the linker command */
    .note.gnu.build-id : {
        *(.note.gnu.build-id)
    } :rodata

    /* Move to the next memory page for `.data` */
    . = ALIGN(CONSTANT(MAXPAGESIZE));

	/* Data section */
    .data : {
        *(.data .data.*)
    } :data

	/* NOTE: `.bss` must be the last thing mapped to `:data` or else lots of unnecessary zeroes will be written to the binary */
	/* If you need for example, `.init_array` and `.fini_array`, those should be placed above this section */
    .bss : {
        *(.bss .bss.*)
        *(COMMON)
    } :data

    /* Discard `.note.*` and `.eh_frame*` since they may cause issues on some hosts */
    /DISCARD/ : {
        *(.eh_frame*)
        *(.note .note.*)
    }
}
