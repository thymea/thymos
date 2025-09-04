pub fn init() void {}
pub fn halt() noreturn {
    while (true) asm volatile ("wfi");
}
