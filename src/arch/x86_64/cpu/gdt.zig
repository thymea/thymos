// Structures
const gdtr_t = packed struct {
    size: u16,
    offset: usize,
};
const gdtEntry_t = packed struct {
    limitLow: u16,
    baseLow: u16,
    baseMid: u8,
    access: u8,
    granularity: u8,
    baseHigh: u8,
};
const tssEntry_t = packed struct {
    limitLow: u16,
    baseLow: u16,
    baseMid: u8,
    access: u8,
    granularity: u8,
    baseHigh: u8,
    baseUpper: u32,
    reserved: u32,
};

// GDT
var gdtr: gdtr_t = undefined;
var gdt: [5]gdtEntry_t = undefined;

// Assembly functions
extern fn loadGDT(gdtr: *const gdtr_t) void;

// Create and load the GDT
pub fn init() void {
    // Disable interrupts until the GDT has been loaded
    asm volatile ("cli");
    defer asm volatile ("sti");

    // Initialize GDTR
    gdtr.offset = @intFromPtr(&gdt[0]);
    gdtr.size = @sizeOf(gdtEntry_t) * gdt.len - 1;

    // Set GDT entries
    setGdtEntry(0, 0, 0);

    // Kernel code and data segment
    setGdtEntry(1, 0x9A, 0xA);
    setGdtEntry(2, 0x92, 0xC);

    // User code and data segment
    setGdtEntry(3, 0xFA, 0xA);
    setGdtEntry(4, 0xF2, 0xC);

    // Load the GDT
    loadGDT(&gdtr);
}

// Set one entry in the GDT
// Long mode ignores base and limit values so we only care about the access byte and flags
fn setGdtEntry(entryNum: u8, access: u8, granularity: u8) void {
    gdt[entryNum].access = access;
    gdt[entryNum].granularity = granularity << 4;
}
