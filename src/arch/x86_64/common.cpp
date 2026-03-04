#include <arch/x86_64/common.hpp>

// Disable system interrupts and halt system indefinitely
[[noreturn]] void CPU::Utils::hlt(void) {
	while(true) {
		__asm__ volatile ("cli");
		__asm__ volatile ("hlt");
	}
}

// Halt system without disabling interrupts
[[noreturn]] void CPU::Utils::idleHlt(void) {
	while(true) __asm__ volatile ("hlt");
}
