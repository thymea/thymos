#pragma once

// Freestanding headers
#include <stddef.h>

// Limine
#include <limine/limine.h>

// Text rendering
#pragma push_macro("__cplusplus")
#undef __cplusplus
#include <ssfn.h>
#pragma pop_macro("__cplusplus")

// Tiny printf implementation
#include <printf/printf.h>

// OS
#include <arch/common.hpp>

typedef struct {
	ssfn_font_t *font;
	uint8_t width, height;
} Font_t;

namespace Drivers {
	class Framebuffer {
		public:
			void init(ssfn_font_t *font, uint32_t bgColor, uint32_t fgColor);
			void clear(void);

			// Getters
			limine_framebuffer *getFramebuffer(void);

		private:
			limine_framebuffer *fb;
	};
}
