#include <arch/x86_64/common.hpp>

namespace cpu::utils {
	// Disable system interrupts and halt system indefinitely
	[[noreturn]] void hlt(void) {
		while(true) {
			__asm__ volatile ("cli");
			__asm__ volatile ("hlt");
		}
	}

	// Halt system without disabling interrupts
	[[noreturn]] void idleHlt(void) {
		while(true) __asm__ volatile ("hlt");
	}
}
