#include <arch/x86_64/idt.hpp>

// Freestanding
#include<cstdint>

// IDT register
typedef struct __attribute__((packed)) {
	uint16_t limit;
	uint64_t base;
} Idtr_t;

// IDT entry descriptor
typedef struct __attribute__((packed)) {
	uint16_t isrLow;
	uint16_t kernelCS;
	uint8_t ist;
	uint8_t attributes;
	uint16_t isrMid;
	uint32_t isrHigh;
	uint32_t reserved;
} IdtEntry_t;

// Interrupt Service Routines (ISRs) - Defined in Assembly
extern void *isrStubTable[];

// IDT - Aligned for performance
__attribute__((aligned(0x10)))
static IdtEntry_t idt[256];
static Idtr_t idtr;

// Create an entry in the IDT
static void idtSetDesc(uint8_t entryNum, void *isr, uint8_t flags) {
	IdtEntry_t *entry {&idt[entryNum]};
	uint64_t isrNum {static_cast<uint64_t>(reinterpret_cast<uintptr_t>(isr))};

	entry->isrLow = isrNum & 0xFFFF;
	entry->kernelCS = 0x08;
	entry->ist = 0;
	entry->attributes = flags;
	entry->isrMid = (isrNum >> 16) & 0xFFFF;
	entry->isrHigh = (isrNum >> 32) & 0xFFFFFFFF;
	entry->reserved = 0;
}

// Constructor
namespace cpu {
	void Idt::init(void) {
		// IDT descriptor
		idtr.base = reinterpret_cast<uintptr_t>(&idt[0]);
		idtr.limit = sizeof(idt) - 1;

		// The 32 CPU exceptions
		for(uint8_t i = 0; i < 32; i++)
			idtSetDesc(i, isrStubTable[i], 0x8E);
		
		// Load the IDT and start interrupts
		__asm__ volatile ("lidt %0" : : "m"(idtr));
		__asm__ volatile ("sti");
	}
}
