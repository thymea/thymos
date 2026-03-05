#pragma once

// Freestanding
#include <cstdint>

// OS
#include <arch/x86_64/common.hpp>

namespace CPU {
	class Idt {
		public:
			void init(void);
		private:
	};
}
