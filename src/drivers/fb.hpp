#pragma once

// Freestanding headers
#include <stddef.h>

// Limine
#include <limine/limine.h>

// OS
#include <utils.hpp>

class Framebuffer {
	public:
		Framebuffer(void);
	private:
		limine_framebuffer *fb {nullptr};
};
