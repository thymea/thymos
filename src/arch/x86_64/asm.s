// Load the GDT
.global loadGDT
loadGDT:
	lgdt (%rdi)

	// Should point to the kernel code segment
	// The kernel CS is the second entry in the GDT
	push $0x08

	// Reload code segments and perform a far return
	lea .reloadCS(%rip), %rax
	push %rax
	lretq
.reloadCS:
	mov $0x10, %ax
	mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
	ret
