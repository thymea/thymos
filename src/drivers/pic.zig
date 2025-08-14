const io = @import("../index.zig").cpu.io;

// Constants
const PIC1: u8 = 0x20;
const PIC2: u8 = 0xA0;
const PIC1_DATA: u8 = (PIC1 + 1);
const PIC2_DATA: u8 = (PIC2 + 1);
const PIC_EOI: u8 = 0x20;
const ICW1_ICW4: u8 = 0x01;
const ICW1_SINGLE: u8 = 0x02;
const ICW1_INTERVAL4: u8 = 0x04;
const ICW1_LEVEL: u8 = 0x08;
const ICW1_INIT: u8 = 0x10;
const ICW4_8086: u8 = 0x01;
const ICW4_AUTO: u8 = 0x02;
const ICW4_BUF_SLAVE: u8 = 0x08;
const ICW4_BUF_MASTER: u8 = 0x0C;
const ICW4_SFNM: u8 = 0x10;
const PIC_READ_IRR: u8 = 0x0a;
const PIC_READ_ISR: u8 = 0x0b;
const CASCADE_IRQ: u8 = 2;

// Helper functions
fn getIrqReg(ocw3: u32) u16 {
    io.outb(PIC1, ocw3);
    io.outb(PIC2, ocw3);
    return (io.inb(PIC2) << 8) | io.inb(PIC1);
}

// Remap the PIC chips
pub fn remap(offset1: u8, offset2: u8) void {
    const a1: u8 = io.inb(PIC1_DATA);
    const a2: u8 = io.inb(PIC2_DATA);

    // Begin initialization sequence in cascade mode
    io.outb(PIC1, ICW1_INIT | ICW1_ICW4);
    io.wait();
    io.outb(PIC2, ICW1_INIT | ICW1_ICW4);
    io.wait();

    // Set PIC vector offsets
    io.outb(PIC1_DATA, offset1);
    io.wait();
    io.outb(PIC2_DATA, offset2);
    io.wait();

    // Tell the master PIC (PIC1) that there's a slave PIC (PIC2) at IRQ 2
    io.outb(PIC1_DATA, 1 << CASCADE_IRQ);
    io.wait();
    io.outb(PIC2_DATA, 2);
    io.wait();

    // Make the PICs use 8086 mode instead of 8080 mode
    io.outb(PIC1_DATA, ICW4_8086);
    io.wait();
    io.outb(PIC2_DATA, ICW4_8086);
    io.wait();

    // Restore the saved masks
    io.outb(PIC1_DATA, a1);
    io.outb(PIC2_DATA, a2);
}

// Mask/Unmask interrupts
pub fn maskIRQ(irqNum: u8) void {
    const port: u16 = if (irqNum < 8) PIC1_DATA else PIC2_DATA;
    const localIRQ: u8 = if (irqNum < 8) irqNum else irqNum - 8;
    const value: u8 = io.inb(port) | (@as(u8, 1) << @as(u3, @intCast(localIRQ)));
    io.outb(port, value);
}
pub fn unmaskIRQ(irqNum: u8) void {
    const port: u16 = if (irqNum < 8) PIC1_DATA else PIC2_DATA;
    const localIRQ: u8 = if (irqNum < 8) irqNum else irqNum - 8;
    const value: u8 = io.inb(port) & ~(@as(u8, 1) << @as(u3, @intCast(localIRQ)));
    io.outb(port, value);
}

// Returns the combined value of the cascaded PICs IRR or ISR
pub fn getIRR() u16 {
    return getIrqReg(PIC_READ_IRR);
}
pub fn getISR() u16 {
    return getIrqReg(PIC_READ_ISR);
}

// Tell the PIC that the interrupt has been handled
pub fn sendEOI(irqNum: u8) void {
    if (irqNum >= 8) io.outb(PIC2, PIC_EOI);
    io.outb(PIC1, PIC_EOI);
}

// Disable the PICs - When using APIC/IOAPIC
pub fn disable() void {
    io.outb(PIC1_DATA, 0xff);
    io.outb(PIC2_DATA, 0xff);
}
