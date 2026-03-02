#define SSFN_CONSOLEBITMAP_TRUECOLOR
#include <drivers/fb.hpp>

// Framebuffer request
__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request fbRequest = {
    .id = LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0,
	.response = nullptr,
};

// Framebuffer pointer
static uint8_t *fbPtr {nullptr};

static font_t font {};

// Initialize framebuffer driver
Framebuffer::Framebuffer(const font_t &_font, uint32_t bgColor, uint32_t fgColor) : fb(fbRequest.response->framebuffers[0]) {
	// Ensure we have a framebuffer and fetch the first available one
	if(this->fb == nullptr) utils::hlt();
	fbPtr = static_cast<uint8_t *>(this->fb->address);

	// Initialize SSFN
	font = _font;
	ssfn_src = font.font;
	ssfn_dst.ptr = (uint8_t *)fb->address;
	ssfn_dst.w = fb->width;
	ssfn_dst.h = fb->height;
	ssfn_dst.p = fb->pitch;
	ssfn_dst.x = ssfn_dst.y = 0;
	ssfn_dst.bg = bgColor;
	ssfn_dst.fg = fgColor;
}

// Clear screen
void Framebuffer::clear(void) {
	return;
}

// Handle printing characters for `printf` and all
void putchar_(char c) {
	bool YOffScreen {(ssfn_dst.y + font.height) > ssfn_dst.h};
	bool XOffScreen {(ssfn_dst.x + font.width) > ssfn_dst.w};

	switch(c) {
		// Newline
		case '\n':
			ssfn_dst.x = 0;
			if(YOffScreen) return;
			else ssfn_dst.y += font.height;
			break;
		
		// Normal character
		default:
			if(YOffScreen || XOffScreen) return;
			else ssfn_putc(c);
			break;
	}
}
