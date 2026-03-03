#pragma once

#include <cstdint>

namespace CPU {
	class GDT {
		public:
			void init(void);
			void setEntry(void);
	};
}
