#pragma once

// Freestanding headers
#include <cstddef>

// Limine
#include <limine/limine.h>

// OS
#include <utils.hpp>

class Framebuffer {
	public:
		Framebuffer(void);
		void drawLine(void);
	private:
		limine_framebuffer *fb {nullptr};
};
