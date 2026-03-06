#pragma once

#include <arch/x86_64/gdt.hpp>
#include <arch/x86_64/idt.hpp>

namespace cpu::utils {
	// Disable system interrupts and halt system indefinitely
	__attribute__((noreturn)) void hlt(void);

	// Halt system without disabling interrupts
	__attribute__((noreturn)) void idleHlt(void);
}
