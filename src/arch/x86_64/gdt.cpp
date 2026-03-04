#include <arch/x86_64/gdt.hpp>

// GDTR - GDT descriptor
typedef struct __attribute__((packed)) {
	uint16_t size;
	uint64_t offset;
} Gdtr_t;

// Segment descriptor
typedef struct __attribute__((packed)) {
	uint16_t limitLow;
	uint16_t baseLow;
	uint8_t baseMid;
	uint8_t access;
	uint8_t granularity; // Limit and flags
	uint8_t baseHigh;
} GdtEntry_t;
typedef struct __attribute__((packed)) {
	GdtEntry_t low;
	uint32_t baseUpper;
	uint32_t reserved;
} TssEntry_t;

// For debugging
#ifdef DEBUG
	// Ensure both structs are actually properly packed and the right size
	static_assert(sizeof(Gdtr_t) == 10, "GDT descriptor structure isn't 10 bytes");
	static_assert(sizeof(GdtEntry_t) == 8, "GDT segment descriptor structure isn't 8 bytes");
	static_assert(sizeof(TssEntry_t) == 16, "TSS segment descriptor structure isn't 16 bytes");
#endif

static Gdtr_t gdtr {};
static GdtEntry_t gdt[5] {};

// Assembly functions
extern "C" {
	extern void loadGDT(Gdtr_t *gdtr);
}

static void setEntry(uint32_t entryNum, uint8_t access, uint8_t gran) {
	GdtEntry_t *entry {&gdt[entryNum]};
	entry->access = access;
	entry->granularity = (gran & 0xF0) | 0x0F;
}

// Load the GDT
void CPU::gdtInit(void) {
	// Disable interrupts
	__asm__ volatile ("cli");

	// Initialize GDT descriptor
	gdtr.offset = reinterpret_cast<uint64_t>(&gdt[0]);
	gdtr.size = sizeof(gdt) - 1;

	// Null segment descriptor
	setEntry(0, 0, 0);

	// Kernel code and data segment descriptors
	setEntry(1, 0x9A, 0x20);
	setEntry(2, 0x92, 0x00);

	// User code and data segment descriptors
	setEntry(3, 0xFA, 0x20);
	setEntry(4, 0xF2, 0x00);

	// Load GDT
	loadGDT(&gdtr);

	// Enable interrupts
	__asm__ volatile ("sti");
}
