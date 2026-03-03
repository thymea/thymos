#include <arch/x86_64/gdt.hpp>

// GDTR - GDT descriptor
typedef struct {
	uint16_t size;
	uint64_t offset;
} __attribute__((packed)) Gdtr_t;

// Segment descriptor
typedef struct {
	uint16_t limitLow;
	uint16_t baseLow;
	uint8_t baseMid;
	uint8_t access;
	uint8_t granularity; // Limit and flags
	uint8_t baseHigh;
	uint32_t baseUpper;
	uint32_t reserved;
} __attribute__((packed)) GdtEntry_t;

static Gdtr_t gdtr {};
static GdtEntry_t gdt[200] {};

void CPU::GDT::init(void) {
	// Initialize GDT descriptor
	gdtr.offset = reinterpret_cast<uintptr_t>(&gdt[0]);
	gdtr.size = sizeof(gdt) - 1;

	// Load GDT
}

void CPU::GDT::setEntry(void) {}
