#include <arch/x86_64/common.hpp>

// Disable system interrupts and halt system indefinitely
__attribute__((noreturn)) void CPU::Utils::hlt(void) {
	for(;;) {
		__asm__ volatile ("cli");
		__asm__ volatile ("hlt");
	}
}

// Halt system without disabling interrupts
__attribute__((noreturn)) void CPU::Utils::idleHlt(void) {
	for(;;) __asm__ volatile ("hlt");
}
