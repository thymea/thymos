.extern interruptHandler

// Macros
.macro isrErrStub interruptNum
	isr_stub_\interruptNum:
		// Pass the error code to the handler as the second argument
		pop %rsi

		// Call the interrupt handler
		mov $\interruptNum, %rdi
		call interruptHandler

		// Return
		iretq
.endm
.macro isrNoErrStub interruptNum
	isr_stub_\interruptNum:
		// Call the interrupt handler
		mov $\interruptNum, %rdi
		xor %rsi, %rsi
		call interruptHandler

		//Return
		iretq
.endm

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

// Load the IDT
.global loadIDT
loadIDT:
	lidt (%rdi)
	ret

// Create interrupt service routines
.rept 48
	.if (\+ == 8) || (\+ == 10) || (\+ == 11) || (\+ == 12) || (\+ == 13) || (\+ == 14) || (\+ == 17) || (\+ == 30)
		isrErrStub \+
	.else
		isrNoErrStub \+
	.endif
.endr

// Place all ISRs in an array that we can easily use
.global isrStubTable
isrStubTable:
	.rept 48
		.quad isr_stub_\+
	.endr
