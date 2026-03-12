pub fn halt() noreturn {
    while (true) asm volatile ("cli; hlt");
}
