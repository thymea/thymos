#pragma once

#include <cstdint>
#include <cstddef>

namespace utils {
	// Disable system interrupts and halt system indefinitely
	void hlt(void);

	// Halt system without disabling interrupts
	void idleHlt(void);
}
