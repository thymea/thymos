#pragma once

// Freestanding headers
#include <stddef.h>

// Limine
#include <limine/limine.h>

// Text rendering
#include <ssfn.h>

// Tiny printf implementation
#include <printf/printf.h>

// OS
#include <utils.hpp>

typedef struct {
	ssfn_font_t *font;
	uint8_t width, height;
} font_t;

class Framebuffer {
	public:
		Framebuffer(const font_t &font, uint32_t bgColor, uint32_t fgColor);
		void clear(void);
	private:
		limine_framebuffer *fb {nullptr};
};
