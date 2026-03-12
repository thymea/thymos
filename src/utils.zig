/// Halts the CPU indefinitely after stopping all interrupts
pub fn halt() noreturn {
    while (true) asm volatile ("cli; hlt");
}
