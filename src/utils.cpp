#include <utils.hpp>

// Disable system interrupts and halt system indefinitely
__attribute__((noreturn)) void utils::hlt(void) {
	for(;;) {
		__asm__ volatile ("cli");
		__asm__ volatile ("hlt");
	}
}

// Halt system without disabling interrupts
__attribute__((noreturn)) void utils::idleHlt(void) {
	for(;;) __asm__ volatile ("hlt");
}
