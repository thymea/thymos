#pragma once

namespace cpu::utils {
	// Disable system interrupts and halt system indefinitely
	[[noreturn]] inline void hlt(void) {
		#ifdef ARCH_x86_64
			while(true) {
				__asm__ volatile ("cli");
				__asm__ volatile ("hlt");
			}
		#endif
	}

	// Halt system without disabling interrupts
	[[noreturn]] inline void idleHlt(void) {
		#ifdef ARCH_x86_64
			while(true) __asm__ volatile ("hlt");
		#endif
	}
}
