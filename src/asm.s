[BITS 64]

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
