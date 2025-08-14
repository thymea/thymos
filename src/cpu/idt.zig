const pic = @import("../drivers/index.zig").pic;

// Types
const irqHandler_t = *const fn (irqNum: u8) void;
const idtr_t = packed struct {
    limit: u16,
    base: u64,
};
const idtEntry_t = packed struct {
    isrLow: u16,
    kernelCS: u16,
    ist: u8,
    attributes: u8,
    isrMid: u16,
    isrHigh: u32,
    reserved: u32,
};

// IDT
var idtr: idtr_t = undefined;
var idt: [256]idtEntry_t align(16) = undefined;

// Hardware interrupt handlers
pub var irqHandlers: [16]?irqHandler_t = .{null} ** 16;

// Assembly code
extern fn loadIDT(idtr: *idtr_t) void;
extern var isrStubTable: [48]*anyopaque;

// CPU exception messages
pub const cpuExceptionMsg: [32][]const u8 = .{
    "Division Error",
    "Debug",
    "Non-Maskable Interrupt",
    "Breakpoint",
    "Overflow",
    "Bound Range Exceeded",
    "Invalid Opcode",
    "Device Not Available",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Invalid TSS",
    "Segment Not Present",
    "Stack-Segment Fault",
    "General Protection Fault",
    "Page Fault",
    "Reserved",
    "x87 Floating-Point Exception",
    "Alignment Check",
    "Machine Check",
    "SIMD Floating-Point Exception",
    "Virtualization Exception",
    "Control Protection Exception",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Hypervisor Injection Exception",
    "VMM Communication Exception",
    "Security Exception",
    "Reserved",
};

// Helper functions
// Set an IDT descriptor
fn setIDTDesc(entry: *idtEntry_t, isr: *anyopaque, flags: u8) void {
    const isrPtr = @intFromPtr(isr);
    entry.isrLow = @intCast(isrPtr & 0xffff);
    entry.kernelCS = 0x08;
    entry.ist = 0;
    entry.attributes = flags;
    entry.isrMid = @intCast((isrPtr >> 16) & 0xffff);
    entry.isrHigh = @intCast((isrPtr >> 32) & 0xffffffff);
    entry.reserved = 0;
}

// Initialize the IDT
pub fn init() void {
    // IDT register
    idtr.base = @intFromPtr(&idt[0]);
    idtr.limit = @sizeOf(idtEntry_t) * idt.len - 1;

    // The 32 CPU exceptions
    for (0..32) |i|
        setIDTDesc(&idt[i], isrStubTable[i], 0x8e);

    // The 16 hardware interrupts
    pic.remap(32, 48);
    for (32..48) |i|
        setIDTDesc(&idt[i], isrStubTable[i], 0x8e);

    // Load the new IDT
    loadIDT(&idtr);
}

// Register/Deregister a hardware interrupt handler
pub fn irqRegisterHandler(irqNum: u8, handler: irqHandler_t) void {
    if (irqNum < irqHandlers.len) {
        irqHandlers[irqNum] = handler;
    } else asm volatile ("cli; hlt");
}
pub fn irqDeregisterHandler(irqNum: u8) void {
    if (irqNum < irqHandlers.len) {
        irqHandlers[irqNum] = null;
    } else asm volatile ("cli; hlt");
}
