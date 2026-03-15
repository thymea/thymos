const root = @import("common");
const colors = @import("colors");
const pic = @import("../drivers/pic.zig");
const c = root.c;
const printf = root.printf;

// Structures
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

// Assembly
extern fn loadIDT(idtr: *idtr_t) void;
extern var isrStubTable: [48]*anyopaque;

// IDT
var idtr: idtr_t = undefined;
var idt: [48]idtEntry_t align(16) = undefined;

// Create and load an IDT
pub fn init() void {
    // Disable interrupts until the IDT has been loaded
    asm volatile ("cli");
    asm volatile ("sti");

    // Initialize IDTR
    idtr.base = @intFromPtr(&idt[0]);
    idtr.limit = @sizeOf(idtEntry_t) * idt.len - 1;

    // Initialize the PICs by remapping them so that they don't cause conflicts with the software interrupts
    // Software interrupts being the CPU exceptions from interrupt 0 to 32
    pic.remap(32, 48);

    // The 32 CPU exceptions and 16 hardware interrupts
    for (0..48) |i|
        setIdtEntry(i, isrStubTable[i], 0x8E);

    // Load the IDT
    loadIDT(&idtr);
}

// Set an entry in the IDT
fn setIdtEntry(entryNum: usize, isr: *anyopaque, flags: u8) void {
    var entry: *idtEntry_t = &idt[entryNum];
    const isrInt: usize = @intFromPtr(isr);
    entry.isrLow = @intCast(isrInt & 0xFFFF);
    entry.kernelCS = 0x08;
    entry.ist = 0;
    entry.attributes = flags;
    entry.isrMid = @intCast((isrInt >> 16) & 0xFFFF);
    entry.isrHigh = @intCast((isrInt >> 32) & 0xFFFFFFFF);
    entry.reserved = 0;
}

// Handle interrupts
export fn interruptHandler(irqNum: u64, errCode: u64) void {
    c.ssfn_dst.fg = colors.ERR_TEXT_COLOR;
    printf("\n[INTERRUPT] %d\n", irqNum);
    printf("[ERROR CODE] %d\n", errCode);
    while (true) asm volatile ("cli; hlt");
}
