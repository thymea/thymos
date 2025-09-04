[BITS 64]

; Macros
; For defining interrupt service routines (ISRs)
%macro isrErrStub 1
  isr%+%1:
    mov rsi, [rsp]      ; Error code
    mov rdi, %1         ; Interrupt number
    call interruptHandler
    add rsp, x08        ; Clean up error code
    iretq
%endmacro
%macro isrNoErrStub 1
  isr%+%1:
    xor rsi, rsi        ; No error code
    mov rdi, %1         ; Interrupt number
    call interruptHandler
    iretq
%endmacro

; Create the 32 CPU exception and the 16 hardware interrupts
%macro createExceptions 0
  %assign i 0
  %rep 32
    %if i = 8 | i = 10 | i = 11 | i = 12 | i = 13 | i = 14 | i = 17 | i = 30
      isrErrStub i
    %else
      isrNoErrStub i
    %endif
    %assign i i+1
  %endrep
%endmacro
%macro createIRQs 0
  %assign i 32
  %rep 16
    isrNoErrStub i
    %assign i i+1
  %endrep
%endmacro

; Code section
section .text
  ; Load the GDT
  global loadGDT
  loadGDT:
    lgdt [rdi]

    ; Reload the code segment
    ; Kernel code segment selector - Index in the GDT
    push 0x08

    ; Load memory address of `.reloadCS` into RAX and push it  to the stack
    lea rax, [rel .reloadCS]
    push rax

    ; Far return to update code segment
    retfq
  .reloadCS:
    ; Reload data segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ret

  ; Create all the interrupt service routines (ISRs)
  extern interruptHandler
  createExceptions
  createIRQs
  global loadIDT, isrStubTable
  loadIDT:
    lidt [rdi]
    ret
  isrStubTable:
    ; The 32 CPU exceptions
    %assign i 0
    %rep 32
      dq isr%+i
      %assign i i+1
    %endrep

    ; The 16 hardware interrupts
    %rep 16
      dq isr%+i
      %assign i i+1
    %endrep
