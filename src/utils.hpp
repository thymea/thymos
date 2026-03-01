#pragma once

namespace utils {
	// Disable system interrupts and halt system indefinitely
	inline void hlt(void) {
		for(;;) {
			__asm__ volatile ("cli");
			__asm__ volatile ("hlt");
		}
	}

	// Halt system without disabling interrupts
	inline void idleHlt(void) {
		for(;;) __asm__ volatile ("hlt");
	}
}
