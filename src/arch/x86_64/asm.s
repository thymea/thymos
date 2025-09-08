.extern interruptHandler

// Macros to quickly and easily create an ISR
.macro isrErrStub interruptNum
  isr\interruptNum:
    movq (%rsp), %rsi
    movq $\interruptNum, %rdi
    call interruptHandler
    addq $8, %rsp
    iretq
.endm
.macro isrNoErrStub interruptNum
  isr\interruptNum:
    xorq %rsi, %rsi
    movq $\interruptNum, %rdi
    call interruptHandler
    iretq
.endm

// Load the GDT
.globl loadGDT
loadGDT:
  lgdt (%rdi)
  pushq $0x08
  leaq .reloadCS(%rip), %rax
  pushq %rax
  lretq
.reloadCS:
  movw $0x10, %ax
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %fs
  movw %ax, %gs
  movw %ax, %ss
  ret

// Load the IDT
.globl loadIDT
loadIDT:
  lidt (%rdi)
  ret

// Create the ISRs and ISR stub table
.globl isrStubTable
.rept 48
  .if (\+ == 8) || (\+ == 10) || (\+ == 11) || (\+ == 12) || (\+ == 13) || (\+ == 14) || (\+ == 17) || (\+ == 30)
    isrErrStub \+
  .else
    isrNoErrStub \+
  .endif
.endr
isrStubTable:
  .rept 48
    .quad isr\+
  .endr
