const g = @import("../index.zig");

// Constants
pub const PAGE_SIZE: usize = 4096;

// Memory maps
export var mmapRequest: g.limine.MemoryMapRequest linksection(".limine_requests") = .{};
export var hhdmRequest: g.limine.HhdmRequest linksection(".limine_requests") = .{};

// Bitmap
var bitmap: [*]volatile u8 = undefined;
var bitmapLen: usize = 0;
var bitmapBasePage: usize = 0;
var bitmapBaseHHDM: [*]volatile u8 = undefined;
var totalPages: usize = 0;
var usedPages: usize = 0;
var hhdmOffset: u64 = 0;
var topPhys: u64 = 0;

// Helpers
inline fn alignUp(x: u64, a: usize) u64 {
    const A: u64 = @intCast(a);
    return (x + (A - 1)) & ~(A - 1);
}
inline fn alignDown(x: u64, a: usize) u64 {
    const A: u64 = @intCast(a);
    return x & ~(A - 1);
}
inline fn bitPos(idx: usize) struct { byte: usize, mask: u8 } {
    return .{ .byte = idx >> 3, .mask = @as(u8, 1) << @as(u3, @intCast(idx & 7)) };
}
fn testBit(idx: usize) bool {
    if (idx >= totalPages) return true;
    const bp = bitPos(idx);
    return bitmapBaseHHDM[bp.byte] & bp.mask != 0;
}
fn setBit(idx: usize, used: bool) void {
    if (idx >= totalPages) return;
    const bp = bitPos(idx);
    var v = bitmapBaseHHDM[bp.byte];
    const before = v;
    if (used) v |= bp.mask else v &= ~bp.mask;
    if (v != before) {
        bitmapBaseHHDM[bp.byte] = v;
        if (used) usedPages += 1 else usedPages -= 1;
    }
}
fn markRangeUsed(base: u64, len: u64) void {
    if (len == 0) return;
    const start = alignDown(base, PAGE_SIZE);
    const end = alignUp(base + len, PAGE_SIZE);
    var p = start;
    while (p < end) : (p += PAGE_SIZE) {
        const idx = p / PAGE_SIZE;
        if (idx >= totalPages) break;
        setBit(idx, true);
    }
}

// Initialize everything
pub fn init() void {
    // Ensure memory maps are available
    if (mmapRequest.response == null or hhdmRequest.response == null) g.halt();

    const mmap = mmapRequest.response.?;
    hhdmOffset = hhdmRequest.response.?.offset;

    // Find highest physical address and largest usable memory region
    var largestIdx: ?usize = null;
    var largestLen: u64 = 0;
    for (mmap.entries.?[0..mmap.entry_count], 0..) |entry, i| {
        const end = entry.base + entry.length;
        if (end > topPhys) topPhys = end;
        if (entry.type == g.limine.MemoryMapType.usable and entry.length > largestLen) {
            largestLen = entry.length;
            largestIdx = i;
        }
    }

    if (largestIdx == null) g.halt();

    totalPages = @intCast(alignUp(topPhys, PAGE_SIZE) / PAGE_SIZE);

    // Compute bitmap size and align to a page (1 bit per page)
    bitmapLen = alignUp((totalPages + 7) / 8, PAGE_SIZE);

    // Place bitmap at start of largest usable memory region
    const bitmapStartPhys = alignUp(mmap.entries.?[largestIdx.?].base, PAGE_SIZE);
    if (bitmapStartPhys + bitmapLen > mmap.entries.?[largestIdx.?].base + mmap.entries.?[largestIdx.?].length) g.halt();
    bitmap = @ptrFromInt(bitmapStartPhys + hhdmOffset);
    bitmapBasePage = bitmapStartPhys / PAGE_SIZE;
    bitmapBaseHHDM = bitmap;

    // Mark all pages free initially
    @memset(bitmap[0..bitmapLen], 0);

    // Reserve regions that shouldn't be given
    // Page 0
    markRangeUsed(0, PAGE_SIZE);

    // Non-usable memory map entries
    for (mmap.entries.?[0..mmap.entry_count]) |entry| {
        if (entry.type != g.limine.MemoryMapType.usable) markRangeUsed(entry.base, entry.length);
    }

    // Bitmap's own pages
    usedPages += bitmapLen / PAGE_SIZE;
    for (0..bitmapLen / PAGE_SIZE) |i| {
        const idx = bitmapBasePage + i;
        const bp = bitPos(idx);
        bitmap[bp.byte] |= bp.mask;
    }
}

// Allocate pages
pub fn allocPage() ?u64 {
    var idx: usize = 0;
    while (idx < totalPages) : (idx += 1) {
        if (!testBit(idx)) {
            setBit(idx, true);
            return idx * PAGE_SIZE;
        }
    }

    // Out of memory
    return null;
}
pub fn allocPages(numPages: usize) ?u64 {
    if (numPages == 0) return null;
    var run: usize = 0;
    var runStart: usize = 0;
    var idx: usize = 0;
    while (idx < totalPages) : (idx += 1) {
        if (!testBit(idx)) {
            if (run == 0) runStart = idx;
            run += 1;
            if (run == numPages) {
                // Mark them used
                var i: usize = 0;
                while (i < numPages) : (i += 1) setBit(runStart + i, true);
                return runStart * PAGE_SIZE;
            }
        } else run = 0;
    }

    // Out of memory
    return null;
}

// Free pages
pub fn freePage(physAddr: u64) void {
    if (physAddr % PAGE_SIZE != 0) g.halt();
    const idx = physAddr / PAGE_SIZE;
    setBit(idx, false);
}
pub fn freePages(physAddr: u64, numPages: usize) void {
    if (physAddr % PAGE_SIZE != 0 or numPages == 0) g.halt();
    const start = physAddr / PAGE_SIZE;
    for (0..numPages) |i| setBit(start + i, false);
}

// Statistics
pub fn stats() struct { total: usize, used: usize, free: usize } {
    return .{
        .total = totalPages,
        .used = usedPages,
        .free = totalPages - usedPages,
    };
}
