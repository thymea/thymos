#pragma once

// OS
#include <arch/x86_64/common.hpp>

namespace cpu {
	class Idt {
		public:
			void init(void);

			// Export a list of error messages for all CPU exceptions
			const char *cpuExceptionMsgs[32] {
				"Division Error",
				"Debug",
				"Non-Maskable Interrupt",
				"Breakpoint",
				"Overflow",
				"Bound Range Exceeded",
				"Invalid Opcode",
				"Device Not Available",
				"Double Fault",
				"Coprocessor Segment Overrun",
				"Invalid Task State Segment (TSS)",
				"Segment Not Present",
				"Stack-Segment Fault",
				"General Protection Fault (GPF)",
				"Page Fault (PF)",
				"Reserved",
				"x87 Floating Point Exception",
				"Alignment Check",
				"Machine Check",
				"SIMD Floating-Point Exception",
				"Virtualization Exception",
				"Control Protection Exception",
				"Reserved",
				"Hypervisor Injection Exception",
				"VMM Communication Exception",
				"Security Exception",
				"Reserved",
				"Triple Fault",
				"FPU Error Interrupt",
			};
	};
}
