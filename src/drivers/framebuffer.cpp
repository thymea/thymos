#define SSFN_CONSOLEBITMAP_TRUECOLOR
#include <drivers/framebuffer.hpp>

// Framebuffer request
__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request fbRequest = {
    .id = LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0,
	.response = nullptr,
};

// Framebuffer pointer
static uint8_t *fbPtr {nullptr};

// Initialize framebuffer driver
void Drivers::Framebuffer::init(ssfn_font_t *font, uint32_t bgColor, uint32_t fgColor) {
	// Ensure we have a framebuffer and fetch the first available one
	if(fbRequest.response == nullptr || fbRequest.response->framebuffer_count < 1) CPU::Utils::hlt();
	this->fb = fbRequest.response->framebuffers[0];
	fbPtr = static_cast<uint8_t *>(this->fb->address);

	// Initialize SSFN
	ssfn_src = font;
	ssfn_dst.ptr = fbPtr;
	ssfn_dst.w = fb->width;
	ssfn_dst.h = fb->height;
	ssfn_dst.p = fb->pitch;
	ssfn_dst.x = ssfn_dst.y = 0;
	ssfn_dst.bg = bgColor;
	ssfn_dst.fg = fgColor;
}

// Clear screen
void Drivers::Framebuffer::clear(void) {
	return;
}

// Getters
limine_framebuffer *Drivers::Framebuffer::getFramebuffer(void) {return this->fb;}
