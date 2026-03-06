[BITS 64]
extern interruptHandler

%macro isrErrStub 1
isr_stub_%+%1:
	; Save CPU state
	push rax
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11

	; Call the interrupt handler
	mov dil, %1 ; Pass the interrupt number
    call interruptHandler

	; Restore CPU state
	pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax

	; Interrupt finished
    iretq
%endmacro
%macro isrNoErrStub 1
isr_stub_%+%1:
	; Save CPU state
	push rax
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r10
    push r11

	; Call the interrupt handler
	mov dil, %1 ; Pass the interrupt number
    call interruptHandler

	; Restore CPU state
	pop r11
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax

	; Interrupt finished
    iretq
%endmacro


section .text
	; Define ISRs (Interrupt Service Routines)
	; The 32 CPU exceptions
	isrNoErrStub 0
	isrNoErrStub 1
	isrNoErrStub 2
	isrNoErrStub 3
	isrNoErrStub 4
	isrNoErrStub 5
	isrNoErrStub 6
	isrNoErrStub 7
	isrErrStub 8
	isrNoErrStub 9
	isrErrStub 10
	isrErrStub 11
	isrErrStub 12
	isrErrStub 13
	isrErrStub 14
	isrNoErrStub 15
	isrNoErrStub 16
	isrErrStub 17
	isrNoErrStub 18
	isrNoErrStub 19
	isrNoErrStub 20
	isrNoErrStub 21
	isrNoErrStub 22
	isrNoErrStub 23
	isrNoErrStub 24
	isrNoErrStub 25
	isrNoErrStub 26
	isrNoErrStub 27
	isrNoErrStub 28
	isrNoErrStub 29
	isrErrStub 30
	isrNoErrStub 31

	; Load the GDT obviously
	global loadGDT
	loadGDT:
		lgdt [rdi]

		; Reload code segment register
		push 0x08
		lea rax, [rel .reloadCS]
		push rax
		retfq
	.reloadCS:
		mov ax, 0x10
		mov ds, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ss, ax
		ret
	
	; ISR stub table
	global isrStubTable
	isrStubTable:
		%assign i 0

		; The 32 CPU exceptions
		%rep 32
			dq isr_stub_%+i
			%assign i i+1
		%endrep
