//! This is the driver for the legacy 8259 PIC (Programmable Interrupt Controller) chip for handling hardware interrupts.
//! APIC (Advanced Programmable Interrupt Controller) is modern and absolutely preferable but that is more complicated
//! to use compared to the PIC so sticking with the 8259 PIC for the time being is an easier way to go.

// Ports
const PIC1_COMMAND: u8 = 0x20;
const PIC1_DATA: u8 = 0x21;
const PIC2_COMMAND: u8 = 0xA0;
const PIC2_DATA: u8 = 0xA1;

// Commands
const PIC_EOI: u8 = 0x20;
const CASCADE_IRQ: u8 = 2;
const PIC_READ_IRR: u8 = 0x0A;
const PIC_READ_ISR: u8 = 0x0B;

// Initialization command words
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

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
        : .{ .memory = true }
    );
}
fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[ret]"
        : [ret] "={al}" (-> u8),
        : [port] "{dx}" (port),
        : .{ .memory = true }
    );
}
fn ioWait() void {
    outb(0x80, 0);
}

/// Initialize the PICs by remapping them so they don't conflict with software interrupts
pub fn remap(offset1: u8, offset2: u8) void {
    // Start initialization sequence in cascade mode
    outb(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
    ioWait();
    outb(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
    ioWait();

    // ICW2 - Set vector offets
    outb(PIC1_DATA, offset1);
    ioWait();
    outb(PIC2_DATA, offset2);
    ioWait();

    // ICW3 - Tell master PIC that there's a slave PIC at IRQ2 and tell slave PIC it's cascade identity
    outb(PIC1_DATA, 1 << CASCADE_IRQ);
    ioWait();
    outb(PIC2_DATA, 2);
    ioWait();

    // ICW4 - Make the PICs use 8086 mode instead of 8080
    outb(PIC1_DATA, ICW4_8086);
    ioWait();
    outb(PIC2_DATA, ICW4_8086);
    ioWait();

    // Mask all hardware interrupts for initially
    // Each interrupt has to be unmasked later on explicitly
    outb(PIC1_DATA, 0xFF);
    outb(PIC2_DATA, 0xFF);
}

// Mask/Unmask an IRQ line
pub fn maskIrq(irq: u8) void {
    const port: u16 = if (irq < 8) PIC1_DATA else PIC2_DATA;
    const value: u8 = if (irq < 8) irq else irq - 8;
    outb(port, inb(port) | (1 << value));
}
pub fn unmaskIrq(irq: u8) void {
    const port: u16 = if (irq < 8) PIC1_DATA else PIC2_DATA;
    const value: u8 = if (irq < 8) irq else irq - 8;
    outb(port, inb(port) & ~(1 << value));
}

/// Read the ISR (In-Service Register) and IRR (Interrupt Request Register)
fn getIrqReg(ocw3: u32) u16 {
    outb(PIC1_COMMAND, ocw3);
    outb(PIC2_COMMAND, ocw3);
    return (inb(PIC2_COMMAND) << 8) | inb(PIC1_COMMAND);
}
pub fn getIRR() u16 {
    return getIrqReg(PIC_READ_IRR);
}
pub fn getISR() u16 {
    return getIrqReg(PIC_READ_ISR);
}

/// Signal that the interrupt has been handled
pub fn sendEOI(irq: u8) void {
    if (irq >= 8) outb(PIC2_COMMAND, PIC_EOI);
    outb(PIC1_COMMAND, PIC_EOI);
}

/// Disable PICs which must be done if we are to use processor local APIC and the IOAPIC
pub fn disable() void {
    outb(PIC1_DATA, 0xFF);
    outb(PIC2_DATA, 0xFF);
}
