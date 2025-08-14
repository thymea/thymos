// Types
const gdtr_t = packed struct {
    size: u16,
    offset: u64,
};
const gdtEntry_t = packed struct {
    limitLow: u16,
    baseLow: u16,
    baseMid: u8,
    access: u8,
    granularity: u8,
    baseHigh: u8,
};

// GDT and GDT register
var gdt: [3]gdtEntry_t = undefined;
var gdtr: gdtr_t = undefined;

// Assembly functions
extern fn loadGDT(gdtr: *gdtr_t) void;

// Create a GDT descriptor
fn setGDTDesc(entry: *gdtEntry_t, base: u64, limit: u32, access: u8, granularity: u8) void {
    entry.baseLow = @intCast(base & 0xffff);
    entry.baseMid = @intCast((base >> 16) & 0xff);
    entry.baseHigh = @intCast((base >> 24) & 0xff);
    entry.limitLow = @intCast(limit & 0xffff);
    entry.granularity = @intCast(((limit >> 16) & 0x0f) | (granularity & 0xf0));
    entry.access = access;
}

// Initialize the GDT
pub fn initGDT() void {
    // Initialize the GDT
    gdtr.size = @sizeOf(gdtEntry_t) * gdt.len - 1;
    gdtr.offset = @intFromPtr(&gdt[0]);

    // Set GDT descriptors - Null and kernel code + data
    setGDTDesc(&gdt[0], 0, 0, 0, 0);
    setGDTDesc(&gdt[1], 0, 0, 0x9a, 0x20);
    setGDTDesc(&gdt[2], 0, 0, 0x92, 0);

    // TODO: Add Task State Segments

    // Load the GDT into the GDT register
    asm volatile ("cli");
    loadGDT(&gdtr);
    asm volatile ("sti");
}
